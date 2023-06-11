import { providerCoinMarketCapApiKey } from "../config/index.js";
import { AssetPair } from "../types/index.js";
import CoinMarketCapProvider from "./CoinMarketCapProvider.js";
import nock from "nock";
import { jest } from "@jest/globals";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const setupNock = (statusCode: number, response: any): void => {
  nock.cleanAll();

  nock("https://pro-api.coinmarketcap.com/v2", {
    reqheaders: {
      "X-CMC_PRO_API_KEY": providerCoinMarketCapApiKey || "",
    },
  })
    .get("/cryptocurrency/quotes/latest")
    .query({ id: "1,1027", aux: "is_active" })
    .reply(statusCode, response);
};

describe("CoinMarketCapProvider", () => {
  let coinMarketCapProvider: CoinMarketCapProvider;
  let pairs: AssetPair[];

  beforeEach(() => {
    coinMarketCapProvider = new CoinMarketCapProvider();
    pairs = [
      { id: 1, baseAssetId: "bitcoin", quoteAssetId: "united-states-dollar" },
      { id: 2, baseAssetId: "ethereum", quoteAssetId: "united-states-dollar" },
    ];

    setupNock(200, {
      data: {
        1: {
          is_active: 1,
          quote: {
            USD: {
              price: 60000,
              last_updated: "2023-05-16T00:00:00.000Z",
            },
          },
        },
        1027: {
          is_active: 1,
          quote: {
            USD: {
              price: 2000,
              last_updated: "2023-05-16T00:00:00.000Z",
            },
          },
        },
      },
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should fetch prices", async () => {
    const prices = await coinMarketCapProvider.fetchPrices(pairs);
    expect(prices).toEqual([
      {
        id: 1,
        baseAssetId: "bitcoin",
        quoteAssetId: "united-states-dollar",
        price: 60000,
        timestamp: 1684195200000,
      },
      {
        id: 2,
        baseAssetId: "ethereum",
        quoteAssetId: "united-states-dollar",
        price: 2000,
        timestamp: 1684195200000,
      },
    ]);
  });

  it("should cache and return prices from cache", async () => {
    await coinMarketCapProvider.fetchPrices(pairs);
    nock.cleanAll();

    const prices = await coinMarketCapProvider.fetchPrices(pairs);
    expect(prices).toEqual([
      {
        id: 1,
        baseAssetId: "bitcoin",
        quoteAssetId: "united-states-dollar",
        price: 60000,
        timestamp: 1684195200000,
      },
      {
        id: 2,
        baseAssetId: "ethereum",
        quoteAssetId: "united-states-dollar",
        price: 2000,
        timestamp: 1684195200000,
      },
    ]);
  });

  it("should handle API errors", async () => {
    setupNock(500, "something awful happened");
    await expect(coinMarketCapProvider.fetchPrices(pairs)).rejects.toThrow(
      "Request failed with status code 500",
    );
  });

  it("should return an empty array if no pairs are provided", async () => {
    const prices = await coinMarketCapProvider.fetchPrices([]);
    expect(prices).toEqual([]);
  });
});
