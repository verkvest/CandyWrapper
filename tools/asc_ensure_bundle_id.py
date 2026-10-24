#!/usr/bin/env python3
"""Register the iOS bundle id with App Store Connect if it does not exist yet.

The App Store Connect *app* record cannot be created with this API.
That step stays manual. This only creates the bundle id.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

import jwt


def main() -> int:
    key_path = os.environ["APPSTORE_KEY_PATH"]
    key_id = os.environ["APPSTORE_API_KEY_ID"]
    issuer = os.environ["APPSTORE_API_ISSUER_ID"]
    bundle = os.environ.get("BUNDLE_ID", "es.verkvest.liltkin")
    name = os.environ.get("BUNDLE_NAME", "Liltkin")
    with open(key_path, "r", encoding="utf-8") as handle:
        key = handle.read()
    now = int(time.time())
    token = jwt.encode(
        {"iss": issuer, "iat": now, "exp": now + 600, "aud": "appstoreconnect-v1"},
        key,
        algorithm="ES256",
        headers={"kid": key_id, "typ": "JWT"},
    )
    if isinstance(token, bytes):
        token = token.decode()

    def call(method: str, url: str, body=None):
        data = None if body is None else json.dumps(body).encode()
        req = urllib.request.Request(url, data=data, method=method)
        req.add_header("Authorization", "Bearer " + token)
        req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                raw = resp.read().decode()
                return resp.status, json.loads(raw) if raw else {}
        except urllib.error.HTTPError as err:
            raw = err.read().decode()
            try:
                parsed = json.loads(raw)
            except json.JSONDecodeError:
                parsed = {"raw": raw}
            return err.code, parsed

    query = urllib.parse.urlencode({"filter[identifier]": bundle})
    status, payload = call("GET", "https://api.appstoreconnect.apple.com/v1/bundleIds?" + query)
    if status != 200:
        print("::error::App Store Connect bundle id lookup failed", status)
        print(json.dumps(payload)[:2000])
        return 1
    existing = payload.get("data") or []
    if existing:
        print("Bundle id already registered:", bundle)
        return 0
    status, payload = call(
        "POST",
        "https://api.appstoreconnect.apple.com/v1/bundleIds",
        {
            "data": {
                "type": "bundleIds",
                "attributes": {
                    "name": name,
                    "identifier": bundle,
                    "platform": "IOS",
                },
            }
        },
    )
    if status in (200, 201):
        print("Registered bundle id", bundle)
        return 0
    if status == 409:
        print("Bundle id already registered (409):", bundle)
        return 0
    # Duplicate identifier sometimes comes back as 409-like 422.
    text = json.dumps(payload)
    if status == 422 and "already" in text.lower():
        print("Bundle id already registered:", bundle)
        return 0
    print("::error::Could not register bundle id", bundle, "HTTP", status)
    print(text[:2000])
    return 1


if __name__ == "__main__":
    sys.exit(main())
