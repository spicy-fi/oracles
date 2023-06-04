import CustomError from "./CustomError.js";

class OutdatedApiResponseError extends CustomError {
  constructor(message = "API response is outdated") {
    super(message);
  }
}

export default OutdatedApiResponseError;
