from typing import Dict, Any, Optional
from Backend.app.services.risk_feature.risk_engine import get_current_risk

async def evaluate_travel_risk(
    latitude: float,
    longitude: float,
    destination: Optional[str] = None,
    travel_time: Optional[str] = None
) -> Dict[str, Any]:
    """
    Assess travel safety around current coordinates or destination route.
    """
    risk_info = await get_current_risk(latitude, longitude)
    level = risk_info.get("level", "LOW")
    hazard = risk_info.get("hazard", "Normal Weather Conditions")

    loc_desc = destination if destination else "around your current location"

    if level in ["HIGH", "CRITICAL"]:
        return {
            "risk_level": level,
            "hazard": hazard,
            "travel_recommendation": f"Travel with High Caution or Delay Trip",
            "reason": f"Severe weather conditions ({hazard.lower()}) detected {loc_desc}.",
            "recommended_action": "Postpone non-essential travel. Avoid low-lying underpasses, expressways, and waterlogged routes."
        }
    elif level == "MODERATE":
        return {
            "risk_level": "MODERATE",
            "hazard": hazard,
            "travel_recommendation": "Proceed with Caution",
            "reason": f"Moderate hazard ({hazard.lower()}) active {loc_desc}.",
            "recommended_action": "Check route visibility, carry wet weather gear or water, and allow 15-20 minutes extra travel time."
        }
    else:
        return {
            "risk_level": "LOW",
            "hazard": "Clear Transit",
            "travel_recommendation": "Safe to Travel",
            "reason": f"Weather conditions {loc_desc} are stable with no active hazard warnings.",
            "recommended_action": "Enjoy your trip! Standard driving rules apply."
        }
