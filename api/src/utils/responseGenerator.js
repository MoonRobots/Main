import { generateHeaders } from "./generateHeaders";

export function generateErrorResponse(error) {
  return {
    statusCode: 500,
    headers: generateHeaders(),
    body: JSON.stringify({
      error: error.message,
    }),
  };
}

export function generateResponse(bodyObject) {
  return {
    statusCode: 200,
    headers: generateHeaders(),
    body: JSON.stringify(bodyObject),
  };
}
