import {
  Wallet,
  JsonRpcProvider,
  TransactionResponse,
  Contract,
  getAddress,
  SigningKey,
  NonceManager,
  toNumber,
} from "ethers";
import { BlockChainAssetPairPrice } from "../types/BlockChainAssetPairPrice.js";
import { debug } from "../config/index.js";
import TransactionFailedError from "../errors/TransactionFailedError.js";
import { getAssetPairSymbolById } from "../helpers/assetPair.js";

class BlockchainService {
  private batchSize: number;
  private eventCount: number;
  private txReceipts: number;
  private txTotal: number;
  private provider: JsonRpcProvider;
  private signer: NonceManager;
  private contract: Contract;

  constructor(options: {
    jsonRpcUrl: string;
    contractAddress: string;
    privateKey: string;
    batchSize: number;
  }) {
    this.batchSize = options.batchSize;
    this.eventCount = 0;
    this.txReceipts = 0;
    this.txTotal = 0;
    this.provider = new JsonRpcProvider(options.jsonRpcUrl);
    this.signer = new NonceManager(
      new Wallet(new SigningKey(options.privateKey), this.provider),
    );
    this.contract = new Contract(
      getAddress(options.contractAddress),
      [
        "event AssetPairPricesUpdated(tuple(bytes32 id, int256 price, uint256 timestamp)[] assetPairPrices)",
        "function updateAssetPairPrices(tuple(bytes32 id, int256 price, uint256 timestamp)[] assetPairPrices)",
      ],
      this.signer,
    );
  }

  public async updateAssetPairPrices(
    prices: BlockChainAssetPairPrice[],
  ): Promise<void> {
    this.txTotal = Math.ceil(prices.length / this.batchSize);

    console.log("Listening for blockchain events...");
    this.contract.on(
      this.contract.filters.AssetPairPricesUpdated,
      (assetPairPrices) => {
        console.log("Received AssetPairPricesUpdated blockchain event:");

        assetPairPrices.forEach((assetPairPrice: BlockChainAssetPairPrice) => {
          console.log(
            "  Updated ",
            assetPairPrice.id,
            getAssetPairSymbolById(toNumber(assetPairPrice.id)),
            assetPairPrice.price.toString(),
            assetPairPrice.timestamp.toString(),
          );
        });

        this.eventCount += 1;
      },
    );

    const transactions: Promise<TransactionResponse>[] = [];

    for (let i = 0; i < prices.length; i += this.batchSize) {
      const batch = prices.slice(i, i + this.batchSize);

      const transaction: Promise<TransactionResponse> =
        this.contract.updateAssetPairPrices(batch);
      transactions.push(transaction);
    }

    console.log(
      `Sending ${this.txTotal} transactions in total... (this may take a while)`,
    );

    const responses: TransactionResponse[] = await Promise.all(transactions);

    for (let i = 0; i < responses.length; i++) {
      const response = responses[i];

      if (debug) {
        console.debug(
          `DEBUG: Transaction Response #${i + 1}`,
          "Hash:",
          response?.hash,
        );
      }

      const receipt = await response.wait();

      if (!receipt?.status) {
        throw new TransactionFailedError(receipt);
      }

      if (debug) {
        console.debug(
          `DEBUG: Transaction Receipt #${i + 1}`,
          "\n",
          "Hash:",
          receipt?.hash,
          "\n",
          "Block hash:",
          receipt?.blockHash,
          "\n",
          "Block number:",
          receipt?.blockNumber,
          "\n",
          "Gas used:",
          receipt?.gasUsed,
          "\n",
          "Gas price:",
          receipt?.gasPrice,
          "\n",
          "Cumulative gas used:",
          receipt?.cumulativeGasUsed,
        );
      }

      this.txReceipts += 1;
    }

    this.waitToEndExecution();
  }

  public waitToEndExecution(): void {
    const wait = setInterval(() => {
      process.stdout.write(".");
      if (
        this.txTotal === this.txReceipts &&
        this.txTotal === this.eventCount
      ) {
        this.provider.removeAllListeners();
        process.stdout.write("\n");
        console.log("----------------------------------------");
        console.log(`Sent ${this.txTotal} transactions in total.`);
        console.log(`Received ${this.eventCount} blockchain events in total.`);
        console.log("Done.");
        clearInterval(wait);
      }
    }, 1000);
  }
}

export default BlockchainService;
