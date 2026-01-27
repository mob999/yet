from fastapi import FastAPI
from .endpoints import user, group
from .database import engine, Base

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Yet API")

app.include_router(user.router, prefix="/users", tags=["users"])
app.include_router(group.router, prefix="/groups", tags=["groups"])

@app.get("/")
def read_root():
    return {"Hello": "Yet"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
