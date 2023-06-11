import { assetPairs } from "../config/index.js";
import { AssetPair } from "../types/index.js";
import { getAssetSymbolById } from "./asset.js";

export function getAssetPairById(id: number): AssetPair {
  const assetPair = assetPairs.find((assetPair) => assetPair.id === id);

  if (assetPair === undefined) {
    throw new Error(`AssetPair with id ${id} not found`);
  }

  return assetPair;
}

export function getAssetPairIdByAssetIds(
  baseAssetId: string,
  quoteAssetId: string,
): AssetPair {
  const assetPair = assetPairs.find(
    (assetPair) =>
      assetPair.baseAssetId === baseAssetId &&
      assetPair.quoteAssetId === quoteAssetId,
  );

  if (assetPair === undefined) {
    throw new Error(
      `AssetPair with baseAssetId ${baseAssetId} and quoteAssetId ${quoteAssetId} not found`,
    );
  }

  return assetPair;
}

export function getAssetPairSymbolById(id: number): string {
  const assetPair = getAssetPairById(id);

  return `${getAssetSymbolById(assetPair.baseAssetId)}${getAssetSymbolById(
    assetPair.quoteAssetId,
  )}`;
}
