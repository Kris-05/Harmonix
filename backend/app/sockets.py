import socketio
import io
from PIL import Image, ImageOps
from app.services.Gesture import AcceptFrames  # Ensure this function accepts byte data correctly
import cv2
import numpy as np

# Create an Async SocketIO server
sioServer = socketio.AsyncServer(
    async_mode='asgi',
    logger=True,  
    cors_allowed_origins=[],  
    async_handlers=True
)

# ASGI app to handle WebSocket connections
sio_app = socketio.ASGIApp(
    socketio_server=sioServer,
    socketio_path='/socket.io'
)

# Event handler for client connection
@sioServer.event
async def connect(sid, environ):
    print(f"Client connected: {sid}")

# Event handler for disconnect
@sioServer.event
async def disconnect(sid):
    print(f"Disconnected: {sid}")

# Handling a custom event called 'frame'
@sioServer.on('frame')
async def send_frames(sid, data):
    print(f"Frame received ::: {sid}")

    try:
        # Decode the raw JPEG/PNG bytes into an image
        frame = cv2.imdecode(np.frombuffer(data, np.uint8), cv2.IMREAD_COLOR)

        if frame is None:
            print("Corrupted image or decoding failed.")
            return

        # Rotate the frame 90 degrees clockwise
        frame = cv2.rotate(frame, cv2.ROTATE_90_CLOCKWISE)

        # Encode the rotated frame back to bytes
        _, encoded_img = cv2.imencode('.jpg', frame)
        img_bytes = encoded_img.tobytes()

        # Send the corrected image bytes to AcceptFrames
        gesture_result = await AcceptFrames(img_bytes)

        print(gesture_result)

        # Emit the gesture result back to the same client
        await sioServer.emit('gesture', {'gesture': gesture_result['gesture']}, room=sid)

    except Exception as e:
        print(f"Error processing frame: {e}")