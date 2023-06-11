import { UnexpectedResponseError } from "../errors/index.js";
import { AssetPair } from "../types/index.js";
import CryptoCompareProvider from "./CryptoCompareProvider.js";
import nock from "nock";
import { jest } from "@jest/globals";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const setupNock = (statusCode: number, response: any): void => {
  nock.cleanAll();

  nock("https://min-api.cryptocompare.com", {
    reqheaders: {
      Authorization: () => true,
    },
  })
    .get("/data/pricemulti")
    .query({
      fsyms: "BTC,ETH",
      tsyms: "USD",
      extraParams: "spicy-price-oracle-fetcher",
    })
    .reply(statusCode, response);
};

describe("CryptoCompareProvider", () => {
  let cryptoCompareProvider: CryptoCompareProvider;
  let pairs: AssetPair[];

  beforeEach(() => {
    cryptoCompareProvider = new CryptoCompareProvider();
    pairs = [
      { id: 1, baseAssetId: "bitcoin", quoteAssetId: "united-states-dollar" },
      { id: 2, baseAssetId: "ethereum", quoteAssetId: "united-states-dollar" },
    ];

    setupNock(200, {
      BTC: { USD: "60000.00" },
      ETH: { USD: "2000.00" },
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should fetch prices", async () => {
    const prices = await cryptoCompareProvider.fetchPrices(pairs);

    expect(prices).toEqual([
      {
        id: 1,
        baseAssetId: "bitcoin",
        quoteAssetId: "united-states-dollar",
        price: "60000.00",
        timestamp: expect.any(Number),
      },
      {
        id: 2,
        baseAssetId: "ethereum",
        quoteAssetId: "united-states-dollar",
        price: "2000.00",
        timestamp: expect.any(Number),
      },
    ]);
  });

  it("should cache and return prices from cache", async () => {
    await cryptoCompareProvider.fetchPrices(pairs);
    nock.cleanAll();

    const prices = await cryptoCompareProvider.fetchPrices(pairs);
    expect(prices).toEqual([
      {
        id: 1,
        baseAssetId: "bitcoin",
        quoteAssetId: "united-states-dollar",
        price: "60000.00",
        timestamp: expect.any(Number),
      },
      {
        id: 2,
        baseAssetId: "ethereum",
        quoteAssetId: "united-states-dollar",
        price: "2000.00",
        timestamp: expect.any(Number),
      },
    ]);
  });

  it("should handle API errors", async () => {
    nock.cleanAll();

    setupNock(500, "something awful happened");

    await expect(cryptoCompareProvider.fetchPrices(pairs)).rejects.toThrow(
      "Request failed with status code 500",
    );
  });

  it("should handle unexpected response data", async () => {
    nock.cleanAll();

    setupNock(200, { BTC: {} });

    await expect(cryptoCompareProvider.fetchPrices(pairs)).rejects.toThrow(
      UnexpectedResponseError,
    );
  });

  it("should return an empty array if no pairs are provided", async () => {
    const prices = await cryptoCompareProvider.fetchPrices([]);
    expect(prices).toEqual([]);
  });
});
