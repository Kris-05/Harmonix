import base64
import cv2
from fastapi import APIRouter, File, HTTPException, Request, UploadFile, status
import numpy as np
from pydantic import BaseModel
from app.services import Gesture

router=APIRouter(tags=["Gesture"])


    
@router.post("/gesture")
async def send_frames(request: Request):
    body = await request.body()
    return await Gesture.AcceptFrames(body)