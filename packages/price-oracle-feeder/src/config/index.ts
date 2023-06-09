import "dotenv/config";
import _assets from "./assets.json" assert { type: "json" };
import _assetPairs from "./assetPairs.json" assert { type: "json" };
import { Asset } from "../types/Asset.js";
import { AssetPair } from "../types/AssetPair.js";

export const assets = _assets as Asset[];
export const assetPairs = _assetPairs as AssetPair[];

export const debug = process.env.DEBUG === "true";
export const mumbaiApiKey = process.env.POLYGON_MUMBAI_API_KEY || "";
export const mumbaiSpicyPriceOracleProxyAddress =
  process.env.POLYGON_MUMBAI_SPICY_PRICE_ORACLE_PROXY_ADDRESS || "";
export const mumbaiSpicyPriceOracleProxyOwnerPK =
  process.env.POLYGON_MUMBAI_SPICY_PRICE_ORACLE_PROXY_OWNER_PK || "";
export const mainnetApiKey = process.env.POLYGON_MAINNET_API_KEY || "";
export const mainnetSpicyPriceOracleProxyAddress =
  process.env.POLYGON_MAINNET_SPICY_PRICE_ORACLE_PROXY_ADDRESS || "";
export const mainnetSpicyPriceOracleProxyOwnerPK =
  process.env.POLYGON_MAINNET_SPICY_PRICE_ORACLE_PROXY_OWNER_PK || "";
export const providerCoinLayerAccessKey =
  process.env.PROVIDER_COIN_LAYER_ACCESS_KEY;
export const providerCoinMarketCapApiKey =
  process.env.PROVIDER_COIN_MARKET_CAP_API_KEY;
export const providerCryptoCompareApiKey =
  process.env.PROVIDER_CRYPTO_COMPARE_API_KEY;
export const port = parseInt(process.env.PORT || "8080");
