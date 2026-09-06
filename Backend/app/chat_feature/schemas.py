from pydantic import BaseModel, EmailStr
import time
from typing import TypedDict, Optional, Annotated
from langchain_core.messages import HumanMessage, AIMessage, ToolMessage, BaseMessage
from datetime import datetime
from langgraph.graph.message import add_messages

class ChatState(TypedDict):
    messages : Annotated[list[BaseMessage], add_messages]

class Query(TypedDict):
    user : str