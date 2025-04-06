import type { TransactionReceipt } from "ethers"
import CustomError from "./CustomError.js"

class TransactionFailedError extends CustomError {
  public readonly receipt: TransactionReceipt | null

  constructor(receipt: TransactionReceipt | null = null) {
    super(receipt ? `Transaction with hash ${receipt.hash} failed.` : "Transaction failed.")
    this.name = "TransactionFailedError"
    this.receipt = receipt

    // This line maintains proper stack trace for where our error was thrown.
    // Only available on V8 (which is used by node and most major browsers)
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, TransactionFailedError)
    }
  }
}

export default TransactionFailedError
