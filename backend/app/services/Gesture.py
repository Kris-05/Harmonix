from collections import Counter
import datetime
from fastapi import FastAPI, File, UploadFile, HTTPException
import cv2
import numpy as np
import mediapipe as mp
from sklearn.preprocessing import StandardScaler  
import tensorflow as tf
from tensorflow.keras.models import load_model
import io
import os


model_path = '/mnt/D/Cipenv/CipServer/app/model/img2.keras'
if not os.path.exists(model_path):
    raise FileNotFoundError(f"Trained model not found at {model_path}")
model = tf.keras.models.load_model(model_path)
scaler = StandardScaler()

# === Load dataset for fitting scaler ===
data_dir = '/mnt/D/Cipenv/CipServer/app/model/ImageDataSet'
actions = ['next', 'previous', 'play', 'next2', 'previous2', 'unknown']
x_data = []
for action in actions:
    file_path = os.path.join(data_dir, f'{action}.npy')
    if os.path.exists(file_path):
        d = np.load(file_path)
        x_data.append(d[:, :-1])
    else:
        print(f"Warning: Missing dataset file {file_path}")
if not x_data:
    raise ValueError("No valid dataset files found!")
x_data = np.concatenate(x_data, axis=0)
scaler.fit(x_data)

# === Mediapipe initialization ===
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1, min_detection_confidence=0.7, min_tracking_confidence=0.7)

# === Decode and Predict ===
def decode_frame(file_bytes):
    try:
        nparr = np.frombuffer(file_bytes, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if frame is None:
            raise ValueError("Invalid image data")
        return frame
    except Exception as e:
        print(f"Error decoding frame: {str(e)}")
        return None

def predict_gesture_from_image(frame):
    img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    result = hands.process(img_rgb)

    if result.multi_hand_landmarks:
        for res in result.multi_hand_landmarks:
            joint = np.zeros((21, 4))
            for j, lm in enumerate(res.landmark):
                joint[j] = [lm.x, lm.y, lm.z, lm.visibility]

            v1 = joint[[0,1,2,3,0,5,6,7,0,9,10,11,0,13,14,15,0,17,18,19], :3]
            v2 = joint[[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20], :3]
            v = v2 - v1
            v = v / np.linalg.norm(v, axis=1)[:, np.newaxis]
            angle = np.arccos(np.einsum('nt,nt->n',
                v[[0,1,2,4,5,6,8,9,10,12,13,14,16,17,18],:],
                v[[1,2,3,5,6,7,9,10,11,13,14,15,17,18,19],:]))
            angle = np.degrees(angle)
            feature = np.concatenate([joint.flatten(), angle])
            feature = scaler.transform([feature])
            
            prediction = model.predict(feature)
            action_idx = np.argmax(prediction)
            confidence = prediction[0][action_idx]
            if confidence < 0.3:
                return "unknown"
            else:
                return actions[action_idx]
    return "no_hand"

MAX_FRAMES = 3
client_predictions = {}


async def AcceptFrames(frame_bytes: bytes):
    try:
        # Convert bytes to NumPy array (image format)
        nparr = np.frombuffer(frame_bytes, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if frame is None:
            raise ValueError("Invalid frame data or unsupported format")

        frame = cv2.rotate(frame, cv2.ROTATE_90_COUNTERCLOCKWISE)
        
        # Predict gesture from the image
        gesture = predict_gesture_from_image(frame)
        pred = gesture

        # Optional timestamp if needed for logs (not saving)
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

        # Commented out the save operation

        frame_filename = f"{gesture}_{timestamp}.jpg"
        cv2.imwrite(frame_filename, frame)    
        sid = "sakthi"

        # Store prediction
        if sid not in client_predictions:
            client_predictions[sid] = []
        client_predictions[sid].append(pred)

        print(f"Received prediction: {pred} | Count: {len(client_predictions[sid])}")

        # Aggregate if enough frames collected
        if len(client_predictions[sid]) >= MAX_FRAMES:
            final_pred = Counter(client_predictions[sid]).most_common(1)[0][0]
            print(f"Final prediction from {MAX_FRAMES} frames: {final_pred}")
            client_predictions[sid].clear()

        print(f"Detected Gesture: {gesture}")
        return {"gesture": gesture}

    except Exception as e:
        print(f"Error processing frame: {str(e)}")
        return {"error": f"Error: {str(e)}"}