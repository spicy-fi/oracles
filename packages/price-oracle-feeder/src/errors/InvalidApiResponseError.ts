import CustomError from "./CustomError.js";

class InvalidApiResponseError extends CustomError {
  constructor(message = "Invalid API response") {
    super(message);
  }
}

export default InvalidApiResponseError;
