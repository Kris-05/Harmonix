import datetime
from fastapi import FastAPI, File, UploadFile, HTTPException
import cv2
import numpy as np
import mediapipe as mp
from tensorflow.keras.models import load_model
import io



# Load gesture prediction model
model = load_model("/mnt/D/Cipenv/CipServer/app/model/modelFinal.h5")

# Define actions and sequence length
actions = ['next', 'previous', 'Pause/Play']
seq_length = 30

# MediaPipe Hands Initialization
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    max_num_hands=1,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5,
)

# Sequence and action storage
seq = []
action_seq = []


# Decode image frame
def decode_frame(file_bytes):
    try:
        nparr = np.frombuffer(file_bytes, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if frame is None:
            raise ValueError("Invalid image data")

        return frame
    except Exception as e:
        print(f"❌ Error decoding frame: {str(e)}")
        return None


# Extract hand landmarks and predict gesture
def predict_gesture(frame):
    global seq, action_seq

    img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    result = hands.process(img_rgb)

    if result.multi_hand_landmarks:
        for res in result.multi_hand_landmarks:
            joint = np.zeros((21, 4))
            for j, lm in enumerate(res.landmark):
                joint[j] = [lm.x, lm.y, lm.z, lm.visibility]

            # Compute angles between joints
            v1 = joint[[0, 1, 2, 3, 0, 5, 6, 7, 0, 9, 10, 11, 0, 13, 14, 15, 0, 17, 18, 19], :3]
            v2 = joint[[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], :3]
            v = v2 - v1
            v = v / np.linalg.norm(v, axis=1)[:, np.newaxis]

            # Get angles using arccos of dot product
            angle = np.arccos(np.einsum('nt,nt->n',
                                        v[[0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 17, 18], :],
                                        v[[1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19], :]))
            angle = np.degrees(angle)

            # Flatten joint data and add angles
            d = np.concatenate([joint.flatten(), angle])
            seq.append(d)

            # Prepare input for model
            if len(seq) < seq_length:
                return "Waiting"

            input_data = np.expand_dims(np.array(seq[-seq_length:], dtype=np.float32), axis=0)

            # Make prediction
            y_pred = model.predict(input_data).squeeze()
            i_pred = int(np.argmax(y_pred))
            conf = y_pred[i_pred]

            if conf < 0.9:
                return "Unknown"

            action = actions[i_pred]
            action_seq.append(action)

            # Confirm action if last 3 predictions match
            if len(action_seq) < 3:
                return "Waiting"

            this_action = "Unknown"
            if action_seq[-1] == action_seq[-2] == action_seq[-3]:
                this_action = action

            return this_action

    return "No Hands Detected"

async def AcceptFrames(frame_bytes: bytes):
    try:
        # Convert raw bytes to numpy array
        nparr = np.frombuffer(frame_bytes, np.uint8)

        # Decode the image (JPEG/PNG) to a frame
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if frame is None:
            raise ValueError("Invalid frame data or unsupported format")
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        frame_filename = f"received_frame_{timestamp}.jpg"
        cv2.imwrite(frame_filename, frame)
        
        #  Process or predict gesture from frame
        gesture = predict_gesture(frame)  # Call your ML function
        print(f"detct Getsur...: {gesture}")
        return {"gesture": gesture}

    except Exception as e:
        print(f" Error processing frame: {str(e)}")
        return {"error": f"Error: {str(e)}"}
