import axios from "axios";
import BulkCurrencyProvider from "./BulkCurrencyProvider.js";
import { AssetPairPrice } from "../types/AssetPairPrice.js";
import { AssetPair } from "../types/index.js";
import { getCoinMarketCapMappingById } from "../helpers/coinMarketCapMapping.js";
import { providerCoinMarketCapApiKey } from "../config/index.js";
import { getAssetPairSymbolById } from "../helpers/assetPair.js";
import { UnexpectedResponseError } from "../errors/index.js";

class CoinMarketCapProvider implements BulkCurrencyProvider {
  public name: string;
  public url: string;
  public cache: Map<string, AssetPairPrice[]>;

  constructor() {
    this.name = "CoinMarketCap";
    this.url = "https://pro-api.coinmarketcap.com/v2";
    this.cache = new Map();
  }

  public async fetchPrices(pairs: AssetPair[]): Promise<AssetPairPrice[]> {
    if (pairs.length === 0) return [];

    const internalIds = pairs
      .map((pair) => getCoinMarketCapMappingById(pair.base))
      .join(",");
    const url = `${this.url}/cryptocurrency/quotes/latest?id=${internalIds}&aux=is_active`;
    const pairPrices = this.cache.get(url) || [];

    if (pairPrices.length !== 0) return pairPrices;

    const response = await axios.get(url, {
      headers: { "X-CMC_PRO_API_KEY": providerCoinMarketCapApiKey },
    });

    for (const pair of pairs) {
      const internalId = getCoinMarketCapMappingById(pair.base);

      if (
        Object.prototype.hasOwnProperty.call(response.data.data, internalId) &&
        response.data.data[internalId].is_active == 1
      ) {
        if (!response.data.data[internalId]?.quote?.USD?.price) {
          throw new UnexpectedResponseError(
            `Unexpected response from ${
              this.name
            } API. No price for ${getAssetPairSymbolById(
              pair.id,
            )} pair (ID: ${internalId}).`,
          );
        }

        pairPrices.push({
          id: pair.id,
          base: pair.base,
          quote: pair.quote,
          price: response.data.data[internalId].quote.USD.price,
          timestamp: new Date(
            response.data.data[internalId].quote.USD.last_updated,
          ).getTime(),
        });
      }
    }

    this.cache.set(url, pairPrices);

    return pairPrices;
  }
}

export default CoinMarketCapProvider;
