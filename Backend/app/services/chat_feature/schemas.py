from typing_extensions import TypedDict, Annotated
from langchain_core.messages import  BaseMessage
from langgraph.graph.message import add_messages

from typing import Optional

class ChatState(TypedDict):
    messages : Annotated[list[BaseMessage], add_messages]

class Query(TypedDict, total=False):
    user : str
    lat : Optional[float]
    long : Optional[float]
    latitude : Optional[float]
    longitude : Optional[float]
    city : Optional[str]
    location_name : Optional[str]
    timestamp : Optional[str]
    timezone : Optional[str]
    destination : Optional[str]
    travel_time : Optional[str]