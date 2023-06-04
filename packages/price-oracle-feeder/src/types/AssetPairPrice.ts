import { AssetPair } from "./AssetPair.js";

export type AssetPairPrice = AssetPair & {
  price: number;
  timestamp: number;
};
