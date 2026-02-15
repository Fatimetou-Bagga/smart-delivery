#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Smart Delivery - Courier (Livreur) Test

Goal:
- Login as courier
- Verify role via /api/auth/me/
- Call GET /api/deliveries/  (this is what your Flutter courier home calls)
- If there is an active delivery (ASSIGNED / IN_PROGRESS):
    - Push GPS points to POST /api/deliveries/location/
    - (Optional) try to set status IN_PROGRESS then DELIVERED via PATCH /api/deliveries/<id>/
      (only if your backend allows courier update)

Requirements:
  pip install requests
"""

import json
import time
import random
from dataclasses import dataclass
from typing import Any, Dict, Optional, Iterable, Union, List

import requests

BASE_URL = "http://localhost:8000"  # change to http://<SERVER_IP>:8000 on real device/LAN

COURIER_USERNAME = "c2"
COURIER_PASSWORD = "12ab34cd56"


# ------------ helpers ------------
def pretty(x: Any) -> str:
    return json.dumps(x, indent=2, ensure_ascii=False, default=str)


class APIError(Exception):
    pass


ExpectedType = Union[int, Iterable[int], None]


@dataclass
class Tokens:
    access: str
    refresh: Optional[str] = None


class API:
    def __init__(self, base_url: str):
        self.base = base_url.rstrip("/")

    def url(self, path: str) -> str:
        if not path.startswith("/"):
            path = "/" + path
        return self.base + path

    def _ok_status(self, code: int, expected: ExpectedType) -> bool:
        if expected is None:
            return True
        if isinstance(expected, int):
            return code == expected
        return code in set(expected)

    def request(
        self,
        method: str,
        path: str,
        token: Optional[str] = None,
        body: Optional[Dict[str, Any]] = None,
        expected: ExpectedType = None,
        timeout: int = 20,
    ) -> requests.Response:
        headers = {"Accept": "application/json"}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        if method.upper() in ("POST", "PATCH", "PUT"):
            headers["Content-Type"] = "application/json"

        r = requests.request(
            method=method.upper(),
            url=self.url(path),
            headers=headers,
            json=body,
            timeout=timeout,
        )

        if expected is not None and not self._ok_status(r.status_code, expected):
            try:
                data = r.json()
            except Exception:
                data = r.text
            raise APIError(
                f"{method.upper()} {path} expected {expected}, got {r.status_code}\nResponse:\n{data}"
            )
        return r

    def get(self, path: str, token: Optional[str] = None, expected: ExpectedType = (200,)):
        return self.request("GET", path, token=token, expected=expected)

    def post(
        self,
        path: str,
        token: Optional[str] = None,
        body: Optional[Dict[str, Any]] = None,
        expected: ExpectedType = (200, 201),
    ):
        return self.request("POST", path, token=token, body=body, expected=expected)

    def patch(
        self,
        path: str,
        token: Optional[str] = None,
        body: Optional[Dict[str, Any]] = None,
        expected: ExpectedType = (200, 202),
    ):
        return self.request("PATCH", path, token=token, body=body, expected=expected)

    # ------------ endpoints ------------
    def login(self, username: str, password: str) -> Tokens:
        data = self.post(
            "/api/auth/login/",
            body={"username": username, "password": password},
            expected=(200, 201),
        ).json()
        return Tokens(access=data["access"], refresh=data.get("refresh"))

    def me(self, token: str) -> Dict[str, Any]:
        return self.get("/api/auth/me/", token=token, expected=(200,)).json()

    def deliveries(self, token: str) -> Any:
        # This is the endpoint your courier app calls
        return self.get("/api/deliveries/", token=token, expected=(200,)).json()

    def push_location(self, token: str, lat: float, lng: float) -> Dict[str, Any]:
        return self.post(
            "/api/deliveries/location/",
            token=token,
            body={"lat": lat, "lng": lng},
            expected=(200, 201),
        ).json()

    def set_delivery_status(self, token: str, delivery_id: int, status_value: str) -> Dict[str, Any]:
        # Optional: only works if your DeliveryViewSet allows PATCH for courier
        return self.patch(
            f"/api/deliveries/{delivery_id}/",
            token=token,
            body={"status": status_value},
            expected=(200, 202),
        ).json()


def _extract_list(payload: Any) -> List[Dict[str, Any]]:
    """
    DRF can return:
    - list
    - {"results": [...]}
    - {"data": [...]}  (if your frontend wrapper exists; here we read raw)
    """
    if isinstance(payload, list):
        return [x for x in payload if isinstance(x, dict)]
    if isinstance(payload, dict):
        if isinstance(payload.get("results"), list):
            return [x for x in payload["results"] if isinstance(x, dict)]
        if isinstance(payload.get("data"), list):
            return [x for x in payload["data"] if isinstance(x, dict)]
    return []


def main():
    api = API(BASE_URL)

    print("\n=== 0) Server sanity check (/swagger/) ===")
    try:
        r = requests.get(f"{BASE_URL}/swagger/", timeout=10)
        print(f"Swagger status: {r.status_code}")
    except Exception as e:
        print("Swagger check failed:", e)

    print("\n=== 1) Courier login ===")
    tokens = api.login(COURIER_USERNAME, COURIER_PASSWORD)
    print("Courier token OK ✅")

    print("\n=== 2) Courier /me ===")
    me = api.me(tokens.access)
    print(pretty(me))
    role = (me.get("role") or me.get("user_type") or "").upper()
    if role and role not in ("COURIER", "LIVREUR"):
        print(f"\n⚠️ WARNING: role returned is '{role}'. Courier endpoints may be blocked.\n")

    print("\n=== 3) GET /api/deliveries/ (this is what Flutter calls) ===")
    deliveries_payload = api.deliveries(tokens.access)
    print("Deliveries response (truncated to 1500 chars):")
    s = pretty(deliveries_payload)
    print(s[:1500] + ("\n..." if len(s) > 1500 else ""))

    deliveries = _extract_list(deliveries_payload)
    if not deliveries:
        print("\n⚠️ No deliveries found for this courier.")
        print("If admin assigned a delivery, confirm a Delivery row exists with courier=c2 in Django admin.")
        return

    # Pick latest active delivery if possible
    def _is_active(d: Dict[str, Any]) -> bool:
        st = str(d.get("status", "")).upper()
        return st in ("ASSIGNED", "IN_PROGRESS", "ACCEPTED")

    active = [d for d in deliveries if _is_active(d)]
    chosen = sorted(active or deliveries, key=lambda x: int(x.get("id", 0)), reverse=True)[0]
    delivery_id = int(chosen.get("id", 0))
    print(f"\nSelected delivery id = {delivery_id}, status = {chosen.get('status')}")

    print("\n=== 4) Push location (10 seconds) ===")
    lat, lng = 33.58990, -7.60390
    start = time.time()
    while time.time() - start < 10:
        lat += random.uniform(-0.0003, 0.0003)
        lng += random.uniform(-0.0003, 0.0003)
        pushed = api.push_location(tokens.access, lat, lng)
        print("[PUSH]", pretty(pushed))
        time.sleep(2)

    print("\n=== 5) (Optional) Try set IN_PROGRESS then DELIVERED ===")
    try:
        upd1 = api.set_delivery_status(tokens.access, delivery_id, "IN_PROGRESS")
        print("PATCH IN_PROGRESS OK:\n", pretty(upd1))
    except Exception as e:
        print("PATCH IN_PROGRESS failed (maybe not allowed):", e)

    try:
        upd2 = api.set_delivery_status(tokens.access, delivery_id, "DELIVERED")
        print("PATCH DELIVERED OK:\n", pretty(upd2))
    except Exception as e:
        print("PATCH DELIVERED failed (maybe not allowed):", e)

    print("\n✅ Courier test completed.")


if __name__ == "__main__":
    main()
