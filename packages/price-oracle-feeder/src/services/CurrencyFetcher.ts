import {
  BulkCurrencyProvider,
  SinglePairCurrencyProvider,
} from "../providers/index.js";
import { AssetPair } from "../types/index.js";
import { NoApiResponseError } from "../errors/index.js";
import { assetPairs, debug } from "../config/index.js";
import { getAssetPairSymbolById } from "../helpers/assetPair.js";
import { AssetPairPrice } from "../types/AssetPairPrice.js";
import { ONE_HOUR_IN_MILLISECONDS } from "../constants.js";

class CurrencyFetcher {
  constructor(
    private singlePairProviders: SinglePairCurrencyProvider[],
    private bulkProviders: BulkCurrencyProvider[],
  ) {}

  public async fetchMedianPrice(assetPair: AssetPair): Promise<AssetPairPrice> {
    const assetPairPrices: AssetPairPrice[] = [];

    // Fetch prices from single-pair providers
    const singlePairFetchPromises = this.singlePairProviders.map(
      async (provider) => {
        try {
          const fetchedAssetPairPrice = await provider.fetchPrice(assetPair);

          if (!fetchedAssetPairPrice) {
            console.log(
              `No valid price data for asset pair ${
                assetPair.id
              } ${getAssetPairSymbolById(assetPair.id)} from provider: ${
                provider.constructor.name
              }`,
            );
            return;
          }

          if (
            Math.abs(Date.now() - fetchedAssetPairPrice.timestamp) >
            60 * 60 * 1000
          ) {
            console.log(
              `Outdated price data for asset pair ${
                assetPair.id
              } ${getAssetPairSymbolById(assetPair.id)} from provider: ${
                provider.constructor.name
              }`,
            );
            return;
          }
          assetPairPrices.push(fetchedAssetPairPrice);
        } catch (err) {
          console.error(
            `Error fetching price from provider: ${provider.constructor.name}`,
            err,
          );
        }
      },
    );

    // Fetch prices from bulk providers
    const bulkFetchPromises = this.bulkProviders.map(async (provider) => {
      try {
        const fetchedAssetPairPrices = await provider.fetchPrices(assetPairs);
        const fetchedAssetPairPrice = fetchedAssetPairPrices.find(
          (f) => f.id === assetPair.id,
        );

        if (!fetchedAssetPairPrice) {
          console.log(
            `No valid price data for asset pair ${
              assetPair.id
            } ${getAssetPairSymbolById(assetPair.id)} from provider: ${
              provider.constructor.name
            }`,
          );
          return;
        }

        if (
          Math.abs(Date.now() - fetchedAssetPairPrice.timestamp) >
          ONE_HOUR_IN_MILLISECONDS
        ) {
          console.log(
            `Outdated price data for asset pair ${
              assetPair.id
            } ${getAssetPairSymbolById(assetPair.id)} from provider: ${
              provider.constructor.name
            }`,
          );
          return;
        }

        if (debug) {
          console.debug(
            "DEBUG: Fetch from:",
            provider.name,
            assetPair.id,
            getAssetPairSymbolById(assetPair.id),
            fetchedAssetPairPrice.price,
            fetchedAssetPairPrice.timestamp,
          );
        }

        assetPairPrices.push(fetchedAssetPairPrice);
      } catch (err) {
        console.error(
          `Error fetching prices from provider: ${provider.constructor.name}`,
          err,
        );
      }
    });

    await Promise.all([...singlePairFetchPromises, ...bulkFetchPromises]);

    if (assetPairPrices.length === 0) {
      throw new NoApiResponseError(
        `No valid price data for asset pair: ${assetPair.id}`,
      );
    }

    assetPairPrices.sort((a, b) => a.price - b.price);

    return assetPairPrices[Math.floor(assetPairPrices.length / 2)];
  }

  public async fetchAllPrices(): Promise<AssetPairPrice[]> {
    const results: AssetPairPrice[] = [];

    console.log("Fetching prices...");

    for (const pair of assetPairs) {
      try {
        const assetPairPrice = await this.fetchMedianPrice(pair);
        results.push(assetPairPrice);

        if (debug) {
          console.debug(
            "DEBUG: Median price for:",
            assetPairPrice.id,
            getAssetPairSymbolById(assetPairPrice.id),
            assetPairPrice.price,
            assetPairPrice.timestamp,
          );
        }
      } catch (err) {
        console.error(`Error fetching prices for pair: ${pair.id}`, err);
        throw err;
      }
    }

    return results;
  }
}

export default CurrencyFetcher;
