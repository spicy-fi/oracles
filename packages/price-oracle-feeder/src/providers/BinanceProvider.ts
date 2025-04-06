import axios from "axios"
import { UnexpectedResponseError } from "../errors/index.js"
import { getAssetPairSymbolById } from "../helpers/assetPair.js"
import type { AssetPairPrice } from "../types/AssetPairPrice.js"
import type { AssetPair } from "../types/index.js"
import type BulkCurrencyProvider from "./BulkCurrencyProvider.js"

class BinanceProvider implements BulkCurrencyProvider {
  public name: string
  public url: string
  public cache: Map<string, AssetPairPrice[]>

  constructor() {
    this.name = "Binance"
    this.url = "https://api.binance.com/api/v3"
    this.cache = new Map()
  }

  public async fetchPrices(pairs: AssetPair[]): Promise<AssetPairPrice[]> {
    if (pairs.length === 0) return []

    const symbols = pairs.map((pair) => getAssetPairSymbolById(pair.id)).join(",")
    const url = `${this.url}/ticker/price?symbols=${symbols}`
    const pairPrices = this.cache.get(url) || []

    if (pairPrices.length !== 0) return pairPrices

    const response = await axios.get(url)
    const currentTime = Date.now()

    for (const pair of pairs) {
      const pairSymbol = getAssetPairSymbolById(pair.id)

      for (const item of response.data) {
        if (item.symbol !== pairSymbol) {
          continue
        }

        if (!item.price) {
          throw new UnexpectedResponseError(
            `Unexpected response from ${this.name} API. No price for ${pairSymbol} pair.`,
          )
        }

        pairPrices.push({
          id: pair.id,
          baseAssetId: pair.baseAssetId,
          quoteAssetId: pair.quoteAssetId,
          price: item.price,
          timestamp: currentTime,
        })
      }
    }

    this.cache.set(url, pairPrices)

    return pairPrices
  }
}

export default BinanceProvider
