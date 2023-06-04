import { assets } from "../config/index.js";
import { Asset } from "../types/index.js";

export function getAssetById(id: string): Asset {
  const asset = assets.find((asset) => asset.id === id);

  if (asset === undefined) {
    throw new Error(`Asset with id ${id} not found`);
  }

  return asset;
}

export function getAssetSymbolById(id: string): string {
  return getAssetById(id).symbol;
}
