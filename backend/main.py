from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from deepface import DeepFace
import cv2
import numpy as np
import os

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust for production
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/detect-emotion")
async def detect_emotion(file: UploadFile = File(...)):
    try:
        # Read image file
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image file")

        # Analyze emotion
        objs = DeepFace.analyze(img, actions=['emotion'], enforce_detection=False)
        emotions = objs[0]['emotion']
        
        # Convert numpy types to native Python types
        required_emotions = {
            key: float(emotions[key])  # Convert numpy.float32 to Python float
            for key in ['angry', 'sad', 'happy', 'neutral']
        }
        
        dominant_emotion = max(required_emotions, key=required_emotions.get)
        print(dominant_emotion)
        return {
            "emotions": required_emotions,
            "dominant_emotion": dominant_emotion
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)