import axios, { AxiosResponse } from "axios";
import BulkCurrencyProvider from "./BulkCurrencyProvider.js";
import { AssetPairPrice } from "../types/AssetPairPrice.js";
import { getCoinGeckoMappingById } from "../helpers/coinGeckoMapping.js";
import { AssetPair } from "../types/index.js";
import { UnexpectedResponseError } from "../errors/index.js";
import { getAssetPairSymbolById } from "../helpers/assetPair.js";

class CoinGeckoProvider implements BulkCurrencyProvider {
  public name: string;
  public url: string;
  public cache: Map<string, AssetPairPrice[]>;
  public maxCalls: number;
  public perMilliseconds: number;
  public callCount: number;

  constructor() {
    this.name = "CoinGecko";
    this.url = "https://api.coingecko.com/api/v3";
    this.cache = new Map();
    this.maxCalls = 500;
    this.perMilliseconds = 60 * 1000; // 1 minute
    this.callCount = 0;
  }

  private sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  private rateLimitedFetch = async (url: string): Promise<AxiosResponse> => {
    if (this.callCount >= this.maxCalls) {
      await this.sleep(this.perMilliseconds);
      this.callCount = 0;
    }

    return axios.get(url);
  };

  public async fetchPrices(pairs: AssetPair[]): Promise<AssetPairPrice[]> {
    if (pairs.length === 0) return [];

    const internalIds = pairs
      .map((pair) => getCoinGeckoMappingById(pair.base))
      .join(",");
    const url = `${this.url}/simple/price?ids=${internalIds}&vs_currencies=usd&include_last_updated_at=true`;
    const pairPrices = this.cache.get(url) || [];

    if (pairPrices.length !== 0) return pairPrices;

    const response = await this.rateLimitedFetch(url);

    for (const pair of pairs) {
      const internalId = getCoinGeckoMappingById(pair.base);

      if (Object.prototype.hasOwnProperty.call(response.data, internalId)) {
        if (!response.data[internalId]?.usd) {
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
          price: response.data[internalId].usd,
          timestamp: response.data[internalId].last_updated_at * 1000,
        });
      }
    }

    this.cache.set(url, pairPrices);

    return pairPrices;
  }
}

export default CoinGeckoProvider;
