from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from fastapi_socketio import SocketManager
import socketio

from app.routers import Accounts, Gesture,playlist

from app.db.database import init_db
from app.services import Gesture as gs


# new Imports
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from deepface import DeepFace
import cv2
import numpy as np
import os
import io
from collections import Counter



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


# Shakith Code BAckend!!!!



def analyze_emotion_custom(img):
    """Custom-tuned emotion detection with SAD sensitivity increased"""
    backends = ['retinaface', 'mtcnn']
    emotions = ['happy', 'sad', 'neutral']
    votes = []
    confidence_scores = {emo: [] for emo in emotions}

    temp_path = "temp_frame.jpg"
    cv2.imwrite(temp_path, img)

    for backend in backends:
        try:
            result = DeepFace.analyze(
                img_path=temp_path,
                actions=['emotion'],
                detector_backend=backend,
                enforce_detection=True,
                silent=True
            )[0]

            emotion_probs = result['emotion']
            dominant = result['dominant_emotion']

            # Biasing toward SAD if neutral and sad are close
            if (
                dominant == 'neutral' and
                emotion_probs['sad'] >= 15  # custom threshold
            ):
                votes.append('sad')
                confidence_scores['sad'].append(emotion_probs['sad'])
            else:
                if dominant in emotions:
                    votes.append(dominant)
                    confidence_scores[dominant].append(emotion_probs[dominant])

        except Exception as e:
            continue

    if os.path.exists(temp_path):
        os.remove(temp_path)

    if votes:
        # Choose most voted
        final_emotion = Counter(votes).most_common(1)[0][0]
        avg_conf = {
            emo: np.mean(scores) if scores else 0
            for emo, scores in confidence_scores.items()
        }

        return {
            "emotions": avg_conf,
            "dominant_emotion": final_emotion,
            "confidence": avg_conf[final_emotion]
        }

    return None


@app.post("/detect-emotion")
async def detect_emotion(file: UploadFile = File(...)):
    """Emotion detection focused on happy/sad/neutral only"""
    try:
        # Read and validate image
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image file")

        # Convert to RGB (required by DeepFace)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # Configure analysis
        backends = ['retinaface', 'mtcnn', 'opencv']  # Ordered by accuracy
        target_emotions = ['happy', 'sad', 'neutral']
        results = []
        confidences = {e: [] for e in target_emotions}

        for backend in backends:
            try:
                analysis = DeepFace.analyze(
                    img_path=img,
                    actions=['emotion'],
                    detector_backend=backend,
                    enforce_detection=True,
                    silent=True
                )[0]

                # Filter and normalize emotions
                raw_scores = analysis['emotion']
                total = sum(raw_scores[e] for e in target_emotions)
                
                if total == 0:  # Skip if no relevant emotions detected
                    continue
                    
                normalized_scores = {
                    e: float(raw_scores[e]) / total * 100
                    for e in target_emotions
                }
                
                # Determine dominant emotion
                dominant = max(normalized_scores.items(), key=lambda x: x[1])[0]
                
                results.append({
                    "emotion": dominant,
                    "scores": normalized_scores,
                    "backend": backend
                })
                
                # Aggregate confidences
                for e in target_emotions:
                    confidences[e].append(normalized_scores[e])

            except Exception as e:
                print(f"Backend {backend} failed: {str(e)}")
                continue
                
            # Exit if we got a good result
            if results:
                break

        if not results:
            raise HTTPException(status_code=400, detail="No face detected or no target emotions found")

        # Calculate weighted averages
        avg_scores = {
            e: float(np.mean(scores)) if scores else 0.0
            for e, scores in confidences.items()
        }
        
        dominant_emotion = max(avg_scores.items(), key=lambda x: x[1])[0]
        
        return {
            "dominant_emotion": dominant_emotion,
            "confidence": avg_scores[dominant_emotion],
            "emotion_scores": avg_scores,
            "detection_backend": results[0]['backend']
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/detect-emotion-enhanced")
async def detect_emotion_enhanced(file: UploadFile = File(...)):
    """Enhanced emotion detection with improved face detection fallback"""
    try:
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image file")

        # Convert to RGB & resize
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, (640, 640))  # optional, but improves detection

        # Save for debugging (optional)
        temp_path = "temp_frame_enhanced.jpg"
        cv2.imwrite(temp_path, img)

        # Add more backends for robustness
        backends = ['retinaface', 'mtcnn', 'opencv']
        emotions = ['happy', 'sad', 'neutral']
        votes = []
        confidences = {e: [] for e in emotions}

        for backend in backends:
            try:
                result = DeepFace.analyze(
                    img,
                    actions=['emotion'],
                    detector_backend=backend,
                    enforce_detection=False,  # TEMP: test even if no face is detected
                    silent=True
                )[0]

                emo_scores = result['emotion']
                emo_scores = {k: float(v) for k, v in emo_scores.items()}

                # Boost sad priority
                if emo_scores.get('sad', 0) > 20:
                    votes.append('sad')
                    confidences['sad'].append(emo_scores['sad'])

                dominant = result['dominant_emotion']
                if dominant in emotions:
                    votes.append(dominant)
                    confidences[dominant].append(emo_scores[dominant])

            except Exception as e:
                print(f"Backend {backend} failed: {e}")
                continue

        # Debug output
        print("Votes:", votes)
        print("Confidences:", confidences)

        if not votes:
            raise HTTPException(status_code=400, detail="No face detected")

        final_emotion = 'sad' if 'sad' in votes else Counter(votes).most_common(1)[0][0]

        avg_conf = {
            e: float(np.mean(s)) if s else 0.0
            for e, s in confidences.items()
        }

        return {
            "emotions": avg_conf,
            "dominant_emotion": final_emotion,
            "confidence": float(avg_conf[final_emotion]),
            "note": "enhanced_sad_detection_with_fallback"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
