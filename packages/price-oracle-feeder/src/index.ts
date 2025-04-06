// Error.stackTraceLimit = 50;

import {
  // mumbaiApiKey,
  // mumbaiSpicyPriceOracleProxyAddress,
  // mumbaiSpicyPriceOracleProxyOwnerPK,
  mainnetApiKey,
  mainnetSpicyPriceOracleProxyAddress,
  mainnetSpicyPriceOracleProxyOwnerPK,
} from "./config/index.js"
import {
  type BulkCurrencyProvider,
  CoinGeckoProvider,
  // CoinLayerProvider,
  CoinMarketCapProvider,
  type SinglePairCurrencyProvider,
  // CryptoCompareProvider,
} from "./providers/index.js"
import AssetPairPriceTransformer from "./services/AssetPairPriceTransformer.js"
import { BlockchainService, CurrencyFetcher } from "./services/index.js"

export default async function main(): Promise<void> {
  const assetPairPriceTransformer = new AssetPairPriceTransformer({
    decimals: 18,
  })

  // const mumbaiBlockchainService = new BlockchainService({
  //   chain: "maticmum",
  //   apiKey: mumbaiApiKey,
  //   contractAddress: mumbaiSpicyPriceOracleProxyAddress,
  //   privateKey: mumbaiSpicyPriceOracleProxyOwnerPK,
  //   batchSize: 30,
  // });

  const mainnetBlockchainService = new BlockchainService({
    chain: "matic",
    apiKey: mainnetApiKey,
    contractAddress: mainnetSpicyPriceOracleProxyAddress,
    privateKey: mainnetSpicyPriceOracleProxyOwnerPK,
    batchSize: 30,
  })

  const singlePairCurrencyProviders: SinglePairCurrencyProvider[] = []
  const bulkCurrencyProviders: BulkCurrencyProvider[] = [
    new CoinGeckoProvider(),
    new CoinMarketCapProvider(),
    // new CryptoCompareProvider(),
    // new CoinLayerProvider(),
  ]

  const currencyFetcher = new CurrencyFetcher(singlePairCurrencyProviders, bulkCurrencyProviders)

  const assetPairPrices = await currencyFetcher.fetchAllPrices()

  const transformedAssetPairPrices = assetPairPriceTransformer.transformBlockChainAssetPairPrice(assetPairPrices)

  // await mumbaiBlockchainService.updateAssetPairPrices(
  //   transformedAssetPairPrices,
  // );

  await mainnetBlockchainService.updateAssetPairPrices(transformedAssetPairPrices)
}

main().catch((error) => console.error("An error occurred:", error))
