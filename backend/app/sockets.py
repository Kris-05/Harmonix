import socketio
from app.services.Gesture import AcceptFrames
# Create an Async SocketIO server
sioServer = socketio.AsyncServer(
    async_mode='asgi',           # Correct async mode for ASGI applications
    logger=True,                 # Enable logging (optional, useful for debugging)
    cors_allowed_origins=[],     # Allow all origins or specify domains
    client_manager=None,         # Optional custom client manager
    namespaces=None,              # Define namespaces if needed
    async_handlers=True          # Use async handlers (default: True)
)

# ASGI app to handle WebSocket connections
sio_app = socketio.ASGIApp(
    socketio_server=sioServer,
    socketio_path='/socket.io'  # Correct WebSocket path
)




# Event handler for client connection
@sioServer.event
async def connect(sid, environ):
    print(f" client connected: {sid}")

# Event handler for disconnect
@sioServer.event
async def disconnect(sid):
    print(f"  disconnected: {sid}")

# Handling a custom event called 'frame'
@sioServer.on('frame')
async def send_frames(sid, data):
    print(f" Frame received ::: {sid}")

    try:
        # Check if the incoming data is bytes (raw RGB bytes)
        if isinstance(data, (bytes, bytearray)):
            # Pass raw bytes directly to AcceptFrames (if it expects bytes)
            gesture_result = await AcceptFrames(data)
        else:
            print(" corrupted data format.")
            return
        
        print(gesture_result)

        # Send acknowledgment back to the client
        await sioServer.emit('ack', {'status': 'received'}, room=sid)

    except Exception as e:
        print(f" Error processing frame: {e}")

