from Backend.app.services.chat_feature.chat_bot import main_func
# append user query to state['messages]
# pass the state it to trigger

# State Schema is of this type :
# class ChatState(TypedDict):
#     messages : Annotated[list[BaseMessage], add_messages]

'''
Maintain a state on backend whose schema is provided.
append user query there.
It will be passed when you call trigger.
It would be modified by trigger and an object returned. Store the object in state. It is the final state.
'''


async def trigger(state):
    if state["messages"][-1].content == "exit":
        return

    out = await main_func(state)
    return out
    