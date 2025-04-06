import CustomError from "./CustomError.js"

class NoApiResponseError extends CustomError {
  constructor(message = "No response from any of the API providers") {
    super(message)
  }
}
export default NoApiResponseError
