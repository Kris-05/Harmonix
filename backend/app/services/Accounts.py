
from bson import ObjectId
from fastapi import HTTPException,status
from motor.motor_asyncio import AsyncIOMotorClient
from app.schema.User import UserModel
from app.utils.utils import hash_password,verify_password
from app.db.database import database,user_collection

# Create a new user
async def create_user(user: UserModel):
# hashing the Password....
    user.email=user.email.lower()
    user.password=hash_password(user.password)
# insertting the Doc in DB........
    user_data = user.dict(by_alias=True)
    user_data.pop("_id", None)
    result = await user_collection.insert_one(user_data) 
    return str(result)


# For Login Account..........
async def loginUserCont(password:str,email:str):
    # finding the email...
    # verify the PassWord...
    # wrong pass

    userEntry=await user_collection.find_one({"email":email.lower()})

    if not userEntry:
        print("No User Found!!")
        raise HTTPException(status_code=401, detail="No User Found!!")
    
    userEntry["_id"] = str(userEntry["_id"]) 
    # print(userEntry) # Convert ObjectId to str
    user=UserModel(**userEntry)
    isCorrectPass=verify_password(password,user.password)

    if not isCorrectPass:
        print("Pass wrng")
        raise HTTPException(status_code=401, detail="Invalid email or password")

    user_dict = user.dict(exclude={"password"})
    return {
        "status_code": status.HTTP_200_OK,
        "message": "Login successful",
        "user": user_dict
    }  


