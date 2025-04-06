import axios from "axios"
import { providerCoinLayerAccessKey } from "../config/index.js"
import { getAssetSymbolById } from "../helpers/asset.js"
import type { AssetPairPrice } from "../types/AssetPairPrice.js"
import type { AssetPair } from "../types/index.js"
import type BulkCurrencyProvider from "./BulkCurrencyProvider.js"

class CoinLayerProvider implements BulkCurrencyProvider {
  public name: string
  public url: string
  public cache: Map<string, AssetPairPrice[]>

  constructor() {
    this.name = "CoinLayer"
    this.url = "http://api.coinlayer.com"
    this.cache = new Map()
  }

  public async fetchPrices(pairs: AssetPair[]): Promise<AssetPairPrice[]> {
    if (pairs.length === 0) return []

    const baseSymbols = pairs.map((pair) => getAssetSymbolById(pair.baseAssetId)).join(",")
    const url = `${this.url}/live?target=USD&symbols=${baseSymbols}&access_key=${providerCoinLayerAccessKey}`
    const pairPrices = this.cache.get(url) || []

    if (pairPrices.length !== 0) return pairPrices

    const response = await axios.get(url)

    for (const pair of pairs) {
      const symbol = getAssetSymbolById(pair.baseAssetId)

      if (Object.prototype.hasOwnProperty.call(response.data.rates, symbol)) {
        pairPrices.push({
          id: pair.id,
          baseAssetId: pair.baseAssetId,
          quoteAssetId: pair.quoteAssetId,
          price: response.data.rates[symbol],
          timestamp: response.data.timestamp * 1000,
        })
      }
    }

    this.cache.set(url, pairPrices)

    return pairPrices
  }
}

export default CoinLayerProvider
