import type { BigNumberish, BytesLike } from "ethers"

export type BlockChainAssetPairPrice = {
  id: BytesLike
  price: BigNumberish
  timestamp: BigNumberish
}
