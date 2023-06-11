import { UnexpectedResponseError } from "../errors/index.js";
import { AssetPair } from "../types/index.js";
import CoinGeckoProvider from "./CoinGeckoProvider.js";
import nock from "nock";
import { jest } from "@jest/globals";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const setupNock = (statusCode: number, response: any): void => {
  nock.cleanAll();

  nock("https://api.coingecko.com")
    .get("/api/v3/simple/price")
    .query({
      ids: "bitcoin,ethereum",
      vs_currencies: "usd",
      include_last_updated_at: "true",
    })
    .reply(statusCode, response);
};

describe("CoinGeckoProvider", () => {
  let coinGeckoProvider: CoinGeckoProvider;
  let pairs: AssetPair[];

  beforeEach(() => {
    coinGeckoProvider = new CoinGeckoProvider();
    pairs = [
      { id: 1, baseAssetId: "bitcoin", quoteAssetId: "united-states-dollar" },
      { id: 2, baseAssetId: "ethereum", quoteAssetId: "united-states-dollar" },
    ];

    setupNock(200, {
      bitcoin: { usd: 60000, last_updated_at: 1684136889 },
      ethereum: { usd: 2000, last_updated_at: 1684136889 },
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should fetch prices", async () => {
    const prices = await coinGeckoProvider.fetchPrices(pairs);

    expect(prices).toEqual([
      {
        id: 1,
        baseAssetId: "bitcoin",
        quoteAssetId: "united-states-dollar",
        price: 60000,
        timestamp: 1684136889000,
      },
      {
        id: 2,
        baseAssetId: "ethereum",
        quoteAssetId: "united-states-dollar",
        price: 2000,
        timestamp: 1684136889000,
      },
    ]);
  });

  it("should cache and return prices from cache", async () => {
    await coinGeckoProvider.fetchPrices(pairs);
    nock.cleanAll();

    const prices = await coinGeckoProvider.fetchPrices(pairs);
    expect(prices).toEqual([
      {
        id: 1,
        baseAssetId: "bitcoin",
        quoteAssetId: "united-states-dollar",
        price: 60000,
        timestamp: 1684136889000,
      },
      {
        id: 2,
        baseAssetId: "ethereum",
        quoteAssetId: "united-states-dollar",
        price: 2000,
        timestamp: 1684136889000,
      },
    ]);
  });

  it("should handle API errors", async () => {
    setupNock(500, "something awful happened");
    await expect(coinGeckoProvider.fetchPrices(pairs)).rejects.toThrow(
      "Request failed with status code 500",
    );
  });

  it("should handle unexpected response data", async () => {
    setupNock(200, { bitcoin: { last_updated_at: 1684136889 } }); // no 'usd' field
    await expect(coinGeckoProvider.fetchPrices(pairs)).rejects.toThrow(
      UnexpectedResponseError,
    );
  });

  it("should return an empty array if no pairs are provided", async () => {
    const prices = await coinGeckoProvider.fetchPrices([]);
    expect(prices).toEqual([]);
  });
});
