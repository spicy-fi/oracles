import { coinGeckoMapping } from "../mappings/index.js"

export function getCoinGeckoMappingById(id: string): string {
  if (coinGeckoMapping[id] === undefined) {
    throw new Error(`CoinGeckoMapping with id ${id} not found`)
  }

  return coinGeckoMapping[id]
}
