import type { AssetPairPrice } from "../types/AssetPairPrice.js"
import type { AssetPair } from "../types/index.js"
import type CurrencyProvider from "./CurrencyProvider.js"

export default interface BulkCurrencyProvider extends CurrencyProvider {
  fetchPrices(pairs: AssetPair[]): Promise<AssetPairPrice[]>
}
