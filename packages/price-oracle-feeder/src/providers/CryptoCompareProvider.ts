import axios from "axios"
import { providerCryptoCompareApiKey } from "../config/index.js"
import { UnexpectedResponseError } from "../errors/index.js"
import { getAssetSymbolById } from "../helpers/asset.js"
import { getAssetPairSymbolById } from "../helpers/assetPair.js"
import type { AssetPairPrice } from "../types/AssetPairPrice.js"
import type { AssetPair } from "../types/index.js"
import type BulkCurrencyProvider from "./BulkCurrencyProvider.js"

class CryptoCompareProvider implements BulkCurrencyProvider {
  public name: string
  public url: string
  public cache: Map<string, AssetPairPrice[]>
  public chunkSize: number

  constructor() {
    this.name = "CryptoCompare"
    this.url = "https://min-api.cryptocompare.com"
    this.cache = new Map()
    this.chunkSize = 30
  }

  public async fetchPrices(pairs: AssetPair[]): Promise<AssetPairPrice[]> {
    let results: AssetPairPrice[] = []

    for (let i = 0; i < pairs.length; i += this.chunkSize) {
      const chunk: AssetPair[] = pairs.slice(i, i + this.chunkSize)
      const chunkPrices = await this.fetchChunkPrices(chunk)
      results = [...results, ...chunkPrices]
    }

    return results
  }

  private async fetchChunkPrices(pairs: AssetPair[]): Promise<AssetPairPrice[]> {
    if (pairs.length === 0) return []

    const baseSymbols = pairs.map((pair) => getAssetSymbolById(pair.baseAssetId)).join(",")
    const url = `${this.url}/data/pricemulti?fsyms=${baseSymbols}&tsyms=USD&extraParams=spicy-price-oracle-fetcher`
    const pairPrices = this.cache.get(url) || []

    if (pairPrices.length !== 0) return pairPrices

    const response = await axios.get(url, {
      headers: { Authorization: `Apikey ${providerCryptoCompareApiKey}` },
    })

    const currentTime = Date.now()

    for (const pair of pairs) {
      const symbol = getAssetSymbolById(pair.baseAssetId)

      if (Object.prototype.hasOwnProperty.call(response.data, symbol)) {
        if (!response.data[symbol]?.USD) {
          throw new UnexpectedResponseError(
            `Unexpected response from ${this.name} API. No price for ${getAssetPairSymbolById(pair.id)} pair.`,
          )
        }

        pairPrices.push({
          id: pair.id,
          baseAssetId: pair.baseAssetId,
          quoteAssetId: pair.quoteAssetId,
          price: response.data[symbol].USD,
          timestamp: currentTime,
        })
      }
    }

    this.cache.set(url, pairPrices)

    return pairPrices
  }
}

export default CryptoCompareProvider
