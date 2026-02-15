import math
import re

from rest_framework import serializers

from .models import DeliveryRequest
from accounts.serializers import UserSerializer
from decimal import Decimal, ROUND_HALF_UP

def _haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Great-circle distance between two points (km)."""
    r = 6371.0
    p1 = math.radians(lat1)
    p2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlmb = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dlmb / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return r * c


def _parse_coords_from_text(text: str):
    """Parse '(lat, lng)' or 'lat,lng' from a string. Returns (lat, lng) or (None, None)."""
    if not text:
        return None, None
    m = re.search(r"(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)", text)
    if not m:
        return None, None
    try:
        return float(m.group(1)), float(m.group(2))
    except Exception:
        return None, None


class DeliveryRequestSerializer(serializers.ModelSerializer):
    client = UserSerializer(read_only=True)

    # computed
    distance_km = serializers.SerializerMethodField()
    price_mru = serializers.SerializerMethodField()

    class Meta:
        model = DeliveryRequest
        fields = [
            "id",
            "client",
            "product_type",
            "description",
            "weight",
            "pickup_address",
            "delivery_address",
            "pickup_lat",
            "pickup_lng",
            "delivery_lat",
            "delivery_lng",
            "distance_km",
            "price_mru",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "client",
            "status",
            "distance_km",
            "price_mru",
            "created_at",
            "updated_at",
        ]

    def _get_pick_drop(self, obj: DeliveryRequest):
        """Prefer explicit fields; fallback to parsing from address strings."""
        plat, plng, dlat, dlng = obj.pickup_lat, obj.pickup_lng, obj.delivery_lat, obj.delivery_lng
        if plat is None or plng is None:
            a, b = _parse_coords_from_text(obj.pickup_address)
            plat = plat if plat is not None else a
            plng = plng if plng is not None else b
        if dlat is None or dlng is None:
            a, b = _parse_coords_from_text(obj.delivery_address)
            dlat = dlat if dlat is not None else a
            dlng = dlng if dlng is not None else b
        return plat, plng, dlat, dlng

    def get_distance_km(self, obj: DeliveryRequest):
        plat, plng, dlat, dlng = self._get_pick_drop(obj)
        if None in (plat, plng, dlat, dlng):
            return None
        return round(_haversine_km(float(plat), float(plng), float(dlat), float(dlng)), 3)

    def _round_to_0_05(self,x: float) -> float:
        # step = 0.05 -> last decimal digit will be 0 or 5
        return float((Decimal(str(x)) / Decimal("0.05")).quantize(Decimal("1"), rounding=ROUND_HALF_UP) * Decimal("0.05"))

    def get_price_mru(self, obj: DeliveryRequest):
        dist = self.get_distance_km(obj)
        if dist is None:
            return None

        raw = dist * 5  # 1 km = 5 MRU
        price = self._round_to_0_05(raw)

        # force 2 decimals in JSON (float), still will be ..x0 or ..x5
        return float(Decimal(str(price)).quantize(Decimal("0.00")))

    def validate(self, attrs):
        """Require coords (recommended) OR allow parsing from address strings."""
        pickup_lat = attrs.get("pickup_lat")
        pickup_lng = attrs.get("pickup_lng")
        delivery_lat = attrs.get("delivery_lat")
        delivery_lng = attrs.get("delivery_lng")

        # If coords missing, try parse from strings (only for create/update payloads)
        if pickup_lat is None or pickup_lng is None:
            a, b = _parse_coords_from_text(attrs.get("pickup_address", ""))
            attrs["pickup_lat"] = pickup_lat if pickup_lat is not None else a
            attrs["pickup_lng"] = pickup_lng if pickup_lng is not None else b
        if delivery_lat is None or delivery_lng is None:
            a, b = _parse_coords_from_text(attrs.get("delivery_address", ""))
            attrs["delivery_lat"] = delivery_lat if delivery_lat is not None else a
            attrs["delivery_lng"] = delivery_lng if delivery_lng is not None else b

        # Still missing? block create.
        if self.instance is None:
            missing = []
            if attrs.get("pickup_lat") is None or attrs.get("pickup_lng") is None:
                missing.append("pickup_lat/pickup_lng")
            if attrs.get("delivery_lat") is None or attrs.get("delivery_lng") is None:
                missing.append("delivery_lat/delivery_lng")
            if missing:
                raise serializers.ValidationError(
                    {
                        "coords": (
                            "Missing coordinates: "
                            + ", ".join(missing)
                            + ". Provide fields or put '(lat, lng)' in the address string."
                        )
                    }
                )

        return attrs
