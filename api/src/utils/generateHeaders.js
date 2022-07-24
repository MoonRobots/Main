// TODO: try to set CORS headers for each response automatically through the Netlify config
export function generateHeaders() {
  return {
    "access-control-allow-credentials": true,
    "access-control-allow-headers": "X-Requested-With,content-type",
    "access-control-allow-methods": "GET, POST, OPTIONS, PUT, PATCH, DELETE",
    "access-control-allow-origin": "*",
  };
}
