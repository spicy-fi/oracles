import { parseUnits, toBeHex } from "ethers"
import { debug } from "../config/index.js"
import { getAssetPairSymbolById } from "../helpers/assetPair.js"
import type { AssetPairPrice } from "../types/AssetPairPrice.js"
import type { BlockChainAssetPairPrice } from "../types/BlockChainAssetPairPrice.js"

class AssetPairPriceTransformer {
  private decimals: number

  constructor(options: { decimals: number }) {
    this.decimals = options.decimals
  }

  private trimDecimalOverflow(n: number, decimals: number): number {
    // Check if n is a number
    if (Number.isNaN(n)) return n

    // Use JavaScript's built-in toFixed method, which correctly rounds the number
    const factor = 10 ** decimals
    return Math.round(n * factor) / factor
  }

  public transformBlockChainAssetPairPrice(assetPairPrices: AssetPairPrice[]): BlockChainAssetPairPrice[] {
    console.log("Transforming to blockchain format...")

    return assetPairPrices.map((assetPairPrice) => {
      const blockChainAssetPairPrice = {
        id: toBeHex(assetPairPrice.id, 32),
        price: parseUnits(this.trimDecimalOverflow(assetPairPrice.price, this.decimals).toString(), this.decimals),
        timestamp: Math.floor(assetPairPrice.timestamp / 1000),
      }

      if (debug) {
        console.debug(
          "DEBUG: Transformed to blockchain format:",
          blockChainAssetPairPrice.id,
          getAssetPairSymbolById(assetPairPrice.id),
          blockChainAssetPairPrice.price,
          blockChainAssetPairPrice.timestamp,
        )
      }

      return blockChainAssetPairPrice
    })
  }
}

export default AssetPairPriceTransformer
