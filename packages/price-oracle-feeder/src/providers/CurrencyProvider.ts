import type { AssetPairPrice } from "../types/AssetPairPrice.js"

export default interface CurrencyProvider {
  name: string
  url: string
  cache: Map<string, AssetPairPrice[]>
}
