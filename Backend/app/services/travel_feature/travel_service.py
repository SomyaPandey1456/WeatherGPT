import urllib.request
import json
from typing import Dict, Any, Optional
from Backend.app.services.risk_feature.risk_engine import get_current_risk

def _geocode_place(place_name: str) -> Optional[Dict[str, Any]]:
    """Geocode a place name using Open-Meteo Geocoding API."""
    try:
        encoded = urllib.parse.quote(place_name)
        url = f"https://geocoding-api.open-meteo.com/v1/search?name={encoded}&count=1&language=en&format=json"
        req = urllib.request.Request(url, headers={'User-Agent': 'WeatherGPT/1.0'})
        with urllib.request.urlopen(req, timeout=4) as resp:
            if resp.status == 200:
                data = json.loads(resp.read().decode())
                results = data.get("results")
                if results and len(results) > 0:
                    first = results[0]
                    return {
                        "name": first.get("name", place_name),
                        "latitude": first.get("latitude"),
                        "longitude": first.get("longitude"),
                        "country": first.get("country", ""),
                        "admin1": first.get("admin1", "")
                    }
    except Exception:
        pass
    return None

async def evaluate_travel_risk(
    latitude: float,
    longitude: float,
    destination: Optional[str] = None,
    travel_time: Optional[str] = None,
    origin_name: Optional[str] = None
) -> Dict[str, Any]:
    """
    Assess travel safety along a route from origin (latitude, longitude) to destination.
    """
    print(f"🚗 TRAVEL ORIGIN: {origin_name or 'Current GPS'} (lat={latitude}, long={longitude})")
    
    origin_risk = await get_current_risk(latitude, longitude)
    
    dest_info = None
    dest_risk = None
    if destination:
        print(f"🚗 TRAVEL DESTINATION: {destination}")
        dest_info = _geocode_place(destination)
        if dest_info and dest_info.get("latitude") and dest_info.get("longitude"):
            dest_risk = await get_current_risk(dest_info["latitude"], dest_info["longitude"])
            print(f"🚗 TRAVEL DESTINATION GEOCODED: {dest_info['name']} (lat={dest_info['latitude']}, long={dest_info['longitude']})")

    # Combine origin and destination risk levels
    levels = [origin_risk.get("level", "LOW")]
    if dest_risk:
        levels.append(dest_risk.get("level", "LOW"))

    if "CRITICAL" in levels:
        overall_level = "CRITICAL"
    elif "HIGH" in levels:
        overall_level = "HIGH"
    elif "MODERATE" in levels:
        overall_level = "MODERATE"
    else:
        overall_level = "LOW"

    hazards = [origin_risk.get("hazard", "Normal Weather Conditions")]
    if dest_risk and dest_risk.get("hazard") != "Normal Weather Conditions":
        hazards.append(dest_risk.get("hazard"))
    hazard_str = ", ".join(list(set(hazards)))

    route_str = f"from {origin_name or 'your origin'} to {dest_info['name'] if dest_info else (destination or 'destination')}"

    if overall_level in ["HIGH", "CRITICAL"]:
        return {
            "risk_level": overall_level,
            "hazard": hazard_str,
            "origin": origin_name or "Current Location",
            "destination": dest_info["name"] if dest_info else (destination or "Unknown"),
            "travel_recommendation": "Travel with High Caution or Delay Trip",
            "reason": f"Severe weather hazard ({hazard_str}) along route {route_str}.",
            "recommended_action": "Postpone non-essential travel. Avoid flooded underpasses, expressways, and low-visibility sectors."
        }
    elif overall_level == "MODERATE":
        return {
            "risk_level": "MODERATE",
            "hazard": hazard_str,
            "origin": origin_name or "Current Location",
            "destination": dest_info["name"] if dest_info else (destination or "Unknown"),
            "travel_recommendation": "Proceed with Caution",
            "reason": f"Moderate weather conditions ({hazard_str}) along route {route_str}.",
            "recommended_action": "Check route visibility, carry wet weather gear or water, and allow 15-20 minutes extra travel time."
        }
    else:
        return {
            "risk_level": "LOW",
            "hazard": "Clear Transit",
            "origin": origin_name or "Current Location",
            "destination": dest_info["name"] if dest_info else (destination or "Destination"),
            "travel_recommendation": "Safe to Travel",
            "reason": f"Weather conditions along route {route_str} are stable with no active hazard warnings.",
            "recommended_action": "Enjoy your trip! Standard driving rules apply."
        }

