from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from loguru import logger

from . import logger as _  # noqa: F401
from .database import Base, engine
from .endpoints.group import api as group_api
from .endpoints.user import api as user_api
from .exceptions import (
    APIException,
    api_exception_handler,
    global_exception_handler,
    validation_exception_handler,
)

# Create tables
Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Application starting up...")
    yield
    # Shutdown
    logger.info("Application shutting down...")


app = FastAPI(title="Yet API", lifespan=lifespan)

# Register Exception Handlers
app.add_exception_handler(APIException, api_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, global_exception_handler)

app.include_router(user_api.router, prefix="/users", tags=["users"])
app.include_router(group_api.router, prefix="/groups", tags=["groups"])

@app.get("/")
def read_root():
    return {"Hello": "Yet"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
