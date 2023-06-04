import { coinMarketCapMapping } from "../mappings/index.js";

export function getCoinMarketCapMappingById(id: string): number {
  if (coinMarketCapMapping[id] === undefined) {
    throw new Error(`CoinMarketCapMapping with id ${id} not found`);
  }

  return coinMarketCapMapping[id];
}
