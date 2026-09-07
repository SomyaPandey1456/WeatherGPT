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


async def chat_node(state : ChatState):
    '''LLM node that may request a tool call or answer based upon it'''
    messages = state['messages']
    response = await llm_with_tools.ainvoke(messages)

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


