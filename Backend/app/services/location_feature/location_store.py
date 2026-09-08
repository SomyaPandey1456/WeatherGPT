from datetime import datetime, timezone
from typing import Dict, Any, Optional

# In-memory store for the current user's location
current_user_location: Dict[str, Any] = {
    "latitude": None,
    "longitude": None,
    "city": None,
    "timestamp": None,
    "timezone": None
}

def update_user_location(
    latitude: float,
    longitude: float,
    timestamp: Optional[str] = None,
    tz: Optional[str] = None,
    city: Optional[str] = None
) -> Dict[str, Any]:
    global current_user_location
    current_user_location["latitude"] = latitude
    current_user_location["longitude"] = longitude
    if city:
        current_user_location["city"] = city
    current_user_location["timestamp"] = timestamp or datetime.now(timezone.utc).isoformat()
    if tz:
        current_user_location["timezone"] = tz
    return current_user_location

def get_user_location() -> Dict[str, Any]:
    return current_user_location

