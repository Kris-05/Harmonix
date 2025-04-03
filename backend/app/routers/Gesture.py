import base64
import cv2
from fastapi import APIRouter, File, HTTPException, UploadFile, status
import numpy as np
from pydantic import BaseModel
from app.services import Gesture

router=APIRouter(tags=["Gesture"])

class FrameData(BaseModel):
    frame: str
    
@router.post("/sendFrames")
async def send_frames(file: UploadFile = File(...)):
    return await Gesture.AcceptFrames(file)

