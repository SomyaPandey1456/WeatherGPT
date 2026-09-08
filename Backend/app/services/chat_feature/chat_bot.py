from langgraph.graph import StateGraph, START, END
from langchain_core.messages import BaseMessage
from langchain_groq import ChatGroq
from dotenv import load_dotenv
from pydantic import SecretStr
from typing import TypedDict, Annotated
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from Backend.app.services.chat_feature.weather_tool import get_weather_now_tool 
from langchain_groq import ChatGroq
import os


load_dotenv()

llm = ChatGroq(
    model="openai/gpt-oss-120b",
    api_key=SecretStr(os.getenv('GROQ_API_KEY') or ''),
    temperature=0.7
)

# list of tools :
tools = [get_weather_now_tool]

# binding tools :
llm_with_tools = llm.bind_tools(tools)


# State Schema 
class ChatState(TypedDict):
    messages : Annotated[list[BaseMessage], add_messages]


from langchain_core.messages import SystemMessage

SYSTEM_INSTRUCTION = SystemMessage(content="""
You are WeatherGPT, a location-aware conversational weather and disaster-intelligence assistant.

STRICT GUIDELINES:
1. SOURCE OF TRUTH: Treat the VERIFIED DEVICE GPS LOCATION and structured weather/risk data provided in the context as absolute fact. The user is physically located at the provided coordinates and city. Never guess or substitute another city (like San Jose, Delhi, or Mumbai) unless the user explicitly asks about that other city.
2. TEMPERATURE UNITS: Always report all temperatures in Celsius (°C). Never use Fahrenheit (°F) unless the user explicitly requests Fahrenheit.
3. ABSOLUTE LOCATION COMPLIANCE: Never mention San Jose, Bay Area, California, Mountain View, or Delhi unless the user's coordinates or query explicitly match those locations.
4. BEAUTIFIED MARKDOWN FORMATTING: Always structure responses clearly using Markdown:
   - Use short bold headers (e.g. ☀️ **Today's Weather**, 🌧️ **Rain Expected**, ⚠️ **MODERATE RISK**, 🚗 **Travel Advisory**)
   - Use bullet points for key metrics (Temperature, Humidity, Rain chance, Wind) with clean emojis.
   - Use concise, conversational paragraphs.
   - Include practical safety notes/tips when hazards or rain exist.
5. NO TECHNICAL NOISE: Never expose raw JSON, Python dicts, API field names, internal variables, coordinates, or technical backend errors to the user.
6. CALM & HELPFUL: Give clear, actionable advice without using alarmist language for low/moderate conditions.
""")


async def chat_node(state : ChatState):
    '''LLM node that may request a tool call or answer based upon context'''
    messages = state['messages']
    # Ensure system instruction is at the start of message trajectory
    if not messages or not isinstance(messages[0], SystemMessage):
        full_messages = [SYSTEM_INSTRUCTION] + list(messages)
    else:
        full_messages = messages

    response = await llm_with_tools.ainvoke(full_messages)

    return {'messages' : [response]}

tool_node = ToolNode(tools)

graph = StateGraph(ChatState)
graph.add_node('chat_node', chat_node)
graph.add_node('tools', tool_node)

graph.add_edge(START, 'chat_node')

graph.add_conditional_edges('chat_node', tools_condition)

graph.add_edge('tools', 'chat_node')


chatbot = graph.compile()

initial_state = {
        'messages': []
    }

async def main_func(state):
    return await chatbot.ainvoke(state)


