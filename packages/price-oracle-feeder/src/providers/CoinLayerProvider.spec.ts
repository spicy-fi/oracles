import { providerCoinLayerAccessKey } from "../config/index.js";
import { AssetPair } from "../types/index.js";
import CoinLayerProvider from "./CoinLayerProvider.js";
import nock from "nock";
import { jest } from "@jest/globals";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const setupNock = (statusCode: number, response: any): void => {
  nock.cleanAll();

  nock("http://api.coinlayer.com")
    .get("/live")
    .query({
      target: "USD",
      symbols: "BTC,ETH",
      access_key: providerCoinLayerAccessKey,
    })
    .reply(statusCode, response);
};

describe("CoinLayerProvider", () => {
  let coinLayerProvider: CoinLayerProvider;
  let pairs: AssetPair[];

  beforeEach(() => {
    coinLayerProvider = new CoinLayerProvider();
    pairs = [
      { id: 1, baseAssetId: "bitcoin", quoteAssetId: "united-states-dollar" },
      { id: 2, baseAssetId: "ethereum", quoteAssetId: "united-states-dollar" },
    ];

    setupNock(200, {
      rates: {
        BTC: 60000,
        ETH: 2000,
      },
      timestamp: 1684136889,
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should fetch prices", async () => {
    const prices = await coinLayerProvider.fetchPrices(pairs);
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
    await coinLayerProvider.fetchPrices(pairs);
    nock.cleanAll();

    const prices = await coinLayerProvider.fetchPrices(pairs);
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
    await expect(coinLayerProvider.fetchPrices(pairs)).rejects.toThrow(
      "Request failed with status code 500",
    );
  });
  //
  it("should return an empty array if no pairs are provided", async () => {
    const prices = await coinLayerProvider.fetchPrices([]);
    expect(prices).toEqual([]);
  });
});
