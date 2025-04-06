import type { AssetPairPrice } from "../types/AssetPairPrice.js"
import type { AssetPair } from "../types/index.js"
import type CurrencyProvider from "./CurrencyProvider.js"

export default interface SinglePairCurrencyProvider extends CurrencyProvider {
  fetchPrice(pair: AssetPair): Promise<AssetPairPrice>
}
