from fastapi import APIRouter
from Backend.app.schemas.chat_schema import ChatRequest, ChatResponse
from Backend.app.services.chat_service import process_chat

router = APIRouter(
    prefix="/chat",
    tags=["Chat"]
)


@router.post("/", response_model=ChatResponse)
async def chat(request: ChatRequest):
    response = await process_chat(request.message)

    return ChatResponse(
        message=response
    )