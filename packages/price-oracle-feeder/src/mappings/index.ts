import type { CoinGeckoMapping, CoinMarketCapMapping } from "../types/index.js"

import _coinGeckoMapping from "./coinGeckoMapping.json" with { type: "json" }
import _coinMarketCapMapping from "./coinMarketCapMapping.json" with { type: "json" }

export const coinGeckoMapping: CoinGeckoMapping = _coinGeckoMapping
export const coinMarketCapMapping: CoinMarketCapMapping = _coinMarketCapMapping
