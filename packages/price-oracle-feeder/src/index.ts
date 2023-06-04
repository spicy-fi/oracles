Error.stackTraceLimit = 50;

import {
  jsonRpcUrl,
  oracleContractAddress,
  oracleOwnerPrivateKey,
} from "./config/index.js";
import {
  BulkCurrencyProvider,
  CoinGeckoProvider,
  CoinLayerProvider,
  CoinMarketCapProvider,
  SinglePairCurrencyProvider,
  CryptoCompareProvider,
} from "./providers/index.js";
import AssetPairPriceTransformer from "./services/AssetPairPriceTransformer.js";
import { BlockchainService, CurrencyFetcher } from "./services/index.js";

export default async function main(): Promise<void> {
  const assetPairPriceTransformer = new AssetPairPriceTransformer({
    decimals: 18,
  });
  const blockchainService = new BlockchainService({
    jsonRpcUrl: jsonRpcUrl,
    contractAddress: oracleContractAddress,
    privateKey: oracleOwnerPrivateKey,
    batchSize: 20,
  });
  const singlePairCurrencyProviders: SinglePairCurrencyProvider[] = [];
  const bulkCurrencyProviders: BulkCurrencyProvider[] = [
    new CoinGeckoProvider(),
    new CoinMarketCapProvider(),
    new CryptoCompareProvider(),
    new CoinLayerProvider(),
  ];

  const currencyFetcher = new CurrencyFetcher(
    singlePairCurrencyProviders,
    bulkCurrencyProviders,
  );

  const assetPairPrices = await currencyFetcher.fetchAllPrices();

  await blockchainService.updateAssetPairPrices(
    assetPairPriceTransformer.transformBlockChainAssetPairPrice(
      assetPairPrices,
    ),
  );
}

main().catch((error) => console.error("An error occurred:", error));
