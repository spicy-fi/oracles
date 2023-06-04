import { AssetPairPrice } from "../types/AssetPairPrice.js";
import { AssetPair } from "../types/index.js";
import CurrencyProvider from "./CurrencyProvider.js";

export default interface SinglePairCurrencyProvider extends CurrencyProvider {
  fetchPrice(pair: AssetPair): Promise<AssetPairPrice>;
}
