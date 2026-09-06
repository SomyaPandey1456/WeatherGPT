from fastapi import FastAPI
import chat_trigger 
import schemas

app = FastAPI()

state = {
    'messages' : []
}

@app.get('/chat_with_bot')
def make_query(query : schemas.Query):
    global state
    state['messages'].append(f'User Message : {query['user']}')
    state = chat_trigger.trigger(state)
    return state['messages'][-1].content
