import { BytesLike, BigNumberish } from "ethers";

export type BlockChainAssetPairPrice = {
  id: BytesLike;
  price: BigNumberish;
  timestamp: BigNumberish;
};
