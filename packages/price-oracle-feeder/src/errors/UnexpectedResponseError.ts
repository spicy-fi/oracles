import CustomError from "./CustomError.js"

class UnexpectedResponseError extends CustomError {
  constructor(message = "Unexpected response") {
    super(message)
  }
}

export default UnexpectedResponseError
