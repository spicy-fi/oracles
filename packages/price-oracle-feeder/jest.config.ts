import "dotenv/config"
import type { JestConfigWithTsJest } from "ts-jest"

const isCI = process.env.CI === "true"

const jestConfig: JestConfigWithTsJest = {
  resetModules: true,
  restoreMocks: true,
  preset: "ts-jest/presets/default-esm",
  testEnvironment: "node",
  testMatch: ["**/?(*.)+(spec|test).[jt]s?(x)"],
  testPathIgnorePatterns: ["/node_modules/", "/build/"],
  extensionsToTreatAsEsm: [".ts"],
  moduleNameMapper: {
    "^(\\.{1,2}/.*)\\.js$": "$1",
  },
  transform: {
    "^.+\\.m?[tj]s?$": [
      "ts-jest",
      {
        useESM: true,
      },
    ],
  },
  coverageDirectory: "coverage",
  collectCoverageFrom: ["src/**/*.ts", "src/**/*.mts", "!src/**/*.d.ts", "!src/**/*.d.mts"],
  coverageReporters: isCI ? ["json"] : ["text"],
}

export default jestConfig
