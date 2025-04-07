from app.db.database import database,user_collection
from bson import ObjectId
from fastapi import HTTPException,status
from motor.motor_asyncio import AsyncIOMotorClient
from app.schema.User import UserModel
import datetime

from app.utils.utils import hash_password

async def CreatePlaylistService(name:str,email:str):
    print("Api for Playlist Creation",name,email)
    userEntry=await user_collection.find_one({"email":email.lower()})
    if not userEntry:
        print("No User Found!!")
        raise HTTPException(status_code=401, detail="No User Found!!")
    userEntry["_id"] = str(userEntry["_id"])  # Convert ObjectId to str
    
    
    new_playlist = {
        "id":hash_password(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")),
        "name": name,
        "owner": email,
        "isLiked": False,
        "isPinned": False,
        "songs": []
    }

    isUpdated=False

    if(not userEntry["playlist"]):
        update_result = await user_collection.update_one(
        {"email": email.lower()},
        {"$set": {"playlist": [new_playlist]}}
        )

        isUpdated=update_result.modified_count != 0

    else:
        update_result = await user_collection.update_one(
            {"email": email.lower()},
            {"$push": {"playlist": new_playlist}}  
        )

        isUpdated=update_result.modified_count != 0
    
   
    if isUpdated == 0:
        raise HTTPException(status_code=500, detail="Failed to create playlist")

    return {
        "status_code": status.HTTP_200_OK,
        "message": "Playlist Creation successful",
    }

async def AddToPlaylistService(playlistId, songs, email,):
    print("Request to add songs to Playlist:", playlistId, songs)
    user = await user_collection.find_one({"email": email.lower(), "playlist.id": playlistId}) #id used HEre

    if not user:
        raise HTTPException(status_code=404, detail="User or Playlist not found")
 
    playlist = next((pl for pl in user["playlist"] if pl["id"] == playlistId), None)
    
    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")
 
    existing_song_ids = [song["id"] for song in playlist["songs"]]
    new_songs = [song for song in songs if song["id"] not in existing_song_ids]
    
    if not new_songs:
        raise HTTPException(status_code=400, detail="All songs are already in the playlist")


    if new_songs:
        update_result = await user_collection.update_one(
            {
                "email": email.lower(),
                "playlist.id": playlistId  #id used here
            },
            {
                "$push": {
                    "playlist.$.songs": { 
                        "$each": [song for song in new_songs]  
                    }
                }
            }
        )
    
        if update_result.modified_count == 0:
            raise HTTPException(status_code=500, detail="Failed to add songs to playlist")
    
        return {
            "status_code": status.HTTP_200_OK,
            "message": "Songs added to playlist successfully"
        }
    
 
    return {
        "status_code": status.HTTP_200_OK,
        "message": "No new songs to add to the playlist"
    }


async def remvoeFromPlaylistService():
    print("remove from Playlist")

async def delPlaylist(name: str, email: str, plid: str): #change Id 
    print(email,name,plid)
    userEntry = await user_collection.find_one({"email": email.lower()})

    if not userEntry:
        print("No User in this email!")
        raise HTTPException(status_code=404, detail="User not found")

    if  not userEntry["playlist"]:
        print("No playlists found ....")
        raise HTTPException(status_code=404, detail="No playlists found")

    updated_playlists = [
        playlist for playlist in userEntry["playlist"]
        if not (playlist["name"] == name and playlist["id"] == plid)
    ]



    if len(updated_playlists) == len(userEntry["playlist"]):
        print("Playlist not found")
        raise HTTPException(status_code=404, detail="Playlist not found")


    update_result = await user_collection.update_one(
        {"email": email.lower()},
        {"$set": {"playlist": updated_playlists}}
    )

    # Check if the update was successful
    if update_result.modified_count == 0:
        raise HTTPException(status_code=500, detail="Failed to delete playlist")

    return {
        "status_code": status.HTTP_200_OK,
        "message": "Playlist deleted ....",
    }

async def pinPlService():
    print("pin Pl")

async def UnpinPlService():
    print("Unpin Pl")

