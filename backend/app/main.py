from contextlib import asynccontextmanager
from fastapi import FastAPI,Request
from app.routers import Accounts
from app.db.database import init_db
app = FastAPI()


# for starting uppp...
# setting indec for Unique property......
@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Initializing database...")
    await init_db()  # Create indexes, etc.
    yield
    print("Cleaning up resources")

# default root
@app.get("/")
def read_root():
    return {"message": " FastAPI is working "}

# adding the routers/....
app.include_router(Accounts.router)
