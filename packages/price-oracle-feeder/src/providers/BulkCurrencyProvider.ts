import { AssetPair } from "../types/index.js";
import { AssetPairPrice } from "../types/AssetPairPrice.js";
import CurrencyProvider from "./CurrencyProvider.js";

export default interface BulkCurrencyProvider extends CurrencyProvider {
  fetchPrices(pairs: AssetPair[]): Promise<AssetPairPrice[]>;
}
