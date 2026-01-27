from fastapi import FastAPI

from .database import Base, engine
from .endpoints.group import api as group_api
from .endpoints.user import api as user_api

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Yet API")

app.include_router(user_api.router, prefix="/users", tags=["users"])
app.include_router(group_api.router, prefix="/groups", tags=["groups"])

@app.get("/")
def read_root():
    return {"Hello": "Yet"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
