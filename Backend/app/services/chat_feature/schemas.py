from typing import Optional, Any
from typing_extensions import TypedDict, Annotated
from langchain_core.messages import BaseMessage
from langgraph.graph.message import add_messages
from pydantic import BaseModel, Field, model_validator

class ChatState(TypedDict):
    messages: Annotated[list[BaseMessage], add_messages]

class Query(BaseModel):
    user: Optional[str] = Field(None, description="User input message or prompt")
    latitude: Optional[float] = Field(None, description="Current device GPS latitude coordinate (-90.0 to 90.0)")
    longitude: Optional[float] = Field(None, description="Current device GPS longitude coordinate (-180.0 to 180.0)")
    city: Optional[str] = Field(None, description="Current city or locality name")
    timestamp: Optional[str] = Field(None, description="Device ISO timestamp string")
    timezone: Optional[str] = Field("Asia/Kolkata", description="Device timezone string (e.g., Asia/Kolkata)")
    destination: Optional[str] = Field(None, description="Travel destination place name (for travel queries)")
    travel_time: Optional[str] = Field(None, description="Target travel departure time (e.g. 4 PM)")

    @model_validator(mode='before')
    @classmethod
    def resolve_coordinate_aliases(cls, data: Any):
        if isinstance(data, dict):
            if data.get('latitude') is None and data.get('lat') is not None:
                data['latitude'] = data.get('lat')
            if data.get('longitude') is None and data.get('long') is not None:
                data['longitude'] = data.get('long')
            if not data.get('city') and data.get('location_name'):
                data['city'] = data.get('location_name')
        return data

    def get(self, key: str, default: Any = None) -> Any:
        """Dict-like access method for backwards compatibility with dictionary code."""
        val = getattr(self, key, default)
        return val if val is not None else default
