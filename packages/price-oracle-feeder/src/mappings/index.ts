import { CoinGeckoMapping, CoinMarketCapMapping } from "../types/index.js";

import _coinGeckoMapping from "./coinGeckoMapping.json" assert { type: "json" };
import _coinMarketCapMapping from "./coinMarketCapMapping.json" assert { type: "json" };

export const coinGeckoMapping: CoinGeckoMapping = _coinGeckoMapping;
export const coinMarketCapMapping: CoinMarketCapMapping = _coinMarketCapMapping;
