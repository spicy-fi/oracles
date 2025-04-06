import { jest } from "@jest/globals"
import nock from "nock"
import { UnexpectedResponseError } from "../errors/index.js"
import type { AssetPair } from "../types/index.js"
import BinanceProvider from "./BinanceProvider.js"

// biome-ignore lint/suspicious/noExplicitAny: i had to do this to make the test work
const setupNock = (statusCode: number, response: any): void => {
  nock.cleanAll()

  nock("https://api.binance.com")
    .get("/api/v3/ticker/price")
    .query({ symbols: "BTCUSD,ETHUSD" })
    .reply(statusCode, response)
}

describe("BinanceProvider", () => {
  let binanceProvider: BinanceProvider
  let pairs: AssetPair[]

  beforeEach(() => {
    binanceProvider = new BinanceProvider()
    pairs = [
      { id: 1, baseAssetId: "bitcoin", quoteAssetId: "united-states-dollar" },
      { id: 2, baseAssetId: "ethereum", quoteAssetId: "united-states-dollar" },
    ]

    setupNock(200, [
      { symbol: "BTCUSD", price: 60000 },
      { symbol: "ETHUSD", price: 2000 },
    ])
  })

  afterEach(() => {
    jest.clearAllMocks()
  })

  it("should fetch prices", async () => {
    const prices = await binanceProvider.fetchPrices(pairs)

    expect(prices).toEqual([
      {
        id: 1,
        baseAssetId: "bitcoin",
        quoteAssetId: "united-states-dollar",
        price: 60000,
        timestamp: expect.any(Number),
      },
      {
        id: 2,
        baseAssetId: "ethereum",
        quoteAssetId: "united-states-dollar",
        price: 2000,
        timestamp: expect.any(Number),
      },
    ])
  })

  it("should cache and return prices from cache", async () => {
    await binanceProvider.fetchPrices(pairs)
    nock.cleanAll()

    const prices = await binanceProvider.fetchPrices(pairs)
    expect(prices).toEqual([
      {
        id: 1,
        baseAssetId: "bitcoin",
        quoteAssetId: "united-states-dollar",
        price: 60000,
        timestamp: expect.any(Number),
      },
      {
        id: 2,
        baseAssetId: "ethereum",
        quoteAssetId: "united-states-dollar",
        price: 2000,
        timestamp: expect.any(Number),
      },
    ])
  })

  it("should handle API errors", async () => {
    setupNock(500, "something awful happened")
    await expect(binanceProvider.fetchPrices(pairs)).rejects.toThrow("Request failed with status code 500")
  })

  it("should handle unexpected response data", async () => {
    setupNock(200, [{ symbol: "BTCUSD" }]) // price field is missing
    await expect(binanceProvider.fetchPrices(pairs)).rejects.toThrow(UnexpectedResponseError)
  })

  it("should return an empty array if no pairs are provided", async () => {
    const prices = await binanceProvider.fetchPrices([])
    expect(prices).toEqual([])
  })
})
