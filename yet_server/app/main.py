from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger

from . import logger as _  # noqa: F401
from .database import Base, engine
from .endpoints.action import api as action_api
from .endpoints.group import api as group_api
from .endpoints.user import api as user_api
from .exceptions import (
    APIException,
    api_exception_handler,
    global_exception_handler,
    validation_exception_handler,
)
from .listeners import register_listeners


# Helper to create tables asynchronously
async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize DB
    logger.info("Application starting up...")
    async with engine.begin() as conn:
        # await conn.run_sync(Base.metadata.drop_all) # Reset DB
        await conn.run_sync(Base.metadata.create_all)
    
    # Register Event Listeners
    register_listeners()
    
    yield
    # Shutdown
    logger.info("Application shutting down...")


app = FastAPI(title="Yet API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register Exception Handlers
app.add_exception_handler(APIException, api_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, global_exception_handler)

app.include_router(user_api.router, prefix="/users", tags=["users"])
app.include_router(group_api.router, prefix="/groups", tags=["groups"])
app.include_router(action_api.router, prefix="/actions", tags=["actions"])

@app.get("/")
def read_root():
    return {"Hello": "Yet"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
