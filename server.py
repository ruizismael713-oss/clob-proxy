"""CLOB Proxy — bypasses Polymarket geoblock by forwarding API calls from a non-US server."""
from flask import Flask, request, Response
import requests

app = Flask(__name__)
CLOB_URL = "https://clob.polymarket.com"

FORWARD_HEADERS = {
    "content-type", "authorization", "poly-api-key",
    "poly-passphrase", "poly-timestamp", "poly-signature",
    "user-agent", "accept", "accept-encoding",
}

@app.route("/health")
def health():
    return {"status": "ok", "clob": CLOB_URL}

@app.route("/<path:path>", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
def proxy(path):
    target = f"{CLOB_URL}/{path}"
    headers = {}
    for h in FORWARD_HEADERS:
        v = request.headers.get(h)
        if v:
            headers[h] = v

    try:
        resp = requests.request(
            method=request.method,
            url=target,
            headers=headers,
            data=request.get_data(),
            params=request.args,
            timeout=30,
        )
        return Response(
            resp.content,
            status=resp.status_code,
            content_type=resp.headers.get("content-type", "application/json"),
        )
    except requests.RequestException as e:
        return {"error": str(e)}, 502

if __name__ == "__main__":
    import os
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
