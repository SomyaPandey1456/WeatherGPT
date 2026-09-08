import math
from typing import List, Dict, Any

# Prototype shelter dataset - clearly marked internally as prototype data
PROTOTYPE_SHELTERS = [
    {
        "id": "shelter_1",
        "name": "Community Relief Center Sector Alpha",
        "address": "Sector Alpha 1, Greater Noida",
        "latitude": 28.4744,
        "longitude": 77.5040,
        "capacity": 500,
        "type": "Community Center",
        "status": "OPEN",
        "contact": "112 / 0120-2320000",
        "is_prototype": True
    },
    {
        "id": "shelter_2",
        "name": "District Indoor Sports Complex",
        "address": "Pari Chowk, Greater Noida",
        "latitude": 28.4670,
        "longitude": 77.5130,
        "capacity": 1200,
        "type": "Sports Complex",
        "status": "OPEN",
        "contact": "112 / 0120-2321111",
        "is_prototype": True
    },
    {
        "id": "shelter_3",
        "name": "Delhi NCR Relief & Emergency Refuge",
        "address": "Connaught Place, Central Delhi",
        "latitude": 28.6315,
        "longitude": 77.2167,
        "capacity": 1500,
        "type": "Civic Center",
        "status": "OPEN",
        "contact": "112 / 011-23340000",
        "is_prototype": True
    },
    {
        "id": "shelter_4",
        "name": "District Multi-Purpose Hall Noida",
        "address": "Sector 62, Noida",
        "latitude": 28.6280,
        "longitude": 77.3649,
        "capacity": 800,
        "type": "Municipal Shelter",
        "status": "OPEN",
        "contact": "112 / 0120-2400000",
        "is_prototype": True
    }
]

def haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate the great-circle distance between two points on the Earth in km."""
    R = 6371.0 # Earth radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

def get_nearby_shelters(latitude: float, longitude: float) -> List[Dict[str, Any]]:
    """
    Return shelters sorted dynamically by distance from current latitude & longitude.
    """
    results = []
    for s in PROTOTYPE_SHELTERS:
        dist = haversine_distance_km(latitude, longitude, s["latitude"], s["longitude"])
        item = dict(s)
        item["distance_km"] = round(dist, 1)
        item["distance_str"] = f"{round(dist, 1)} km away"
        results.append(item)

    # Sort by distance
    results.sort(key=lambda x: x["distance_km"])
    return results
