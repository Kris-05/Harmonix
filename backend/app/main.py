from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from fastapi_socketio import SocketManager
import socketio

from app.routers import Accounts, Gesture,playlist

from app.db.database import init_db
from app.services import Gesture as gs




from app.sockets import sio_app
app = FastAPI()



app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/socket.io", sio_app)


@asynccontextmanager
async def lifespan(app: FastAPI):
    print(" Initializing database")
    await init_db() 
    yield
    print(" Cleaning up resources")


@app.get("/")
def read_root():
    return {"message": "FastAPI is working"}



app.include_router(Accounts.router)
app.include_router(Gesture.router)
app.include_router(playlist.router)
