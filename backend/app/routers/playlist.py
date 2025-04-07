from fastapi import APIRouter, HTTPException, Query, status
from pydantic import BaseModel
from app.services import playlist
from motor.motor_asyncio import AsyncIOMotorClient
from app.db.database import database,user_collection

router=APIRouter(
    prefix="/playlist"
    ,tags=["Playlist"]
)


class plModel(BaseModel):
    name:str
    email :str


@router.post("/createPlaylist")
async def createPlaylist(pl:plModel):
    print(pl.name)
    return await playlist.CreatePlaylistService(pl.name,pl.email)



@router.post("/removeFromPlaylist")
async def removeSong():
    await playlist.remvoeFromPlaylistService()



class dlModel (BaseModel):
    name: str
    email: str
    id:str

@router.post("/deletePlaylist")
async def deletePlaylist(dl:dlModel):
    return await playlist.delPlaylist(dl.name,dl.email,dl.id)


@router.post("/pinPl")
async def pinPl():
    await playlist.pinPlService()


@router.post("/unPinPl")
async def unPinPl():
    await playlist.UnpinPlService()

class SongModel(BaseModel):
    name:str
    id:str

class AddSongModel(BaseModel):
    id:str
    songs:list[SongModel]
    email:str


# for ading the Songs to the PlayList...
@router.post("/addToPlaylist")
async def addSongToPlaylist(inp:AddSongModel):

    playlistId=inp.id
    inpDic=inp.dict(by_alias=True)
    songs=inpDic['songs'] if inpDic and inpDic['songs'] else []
    email=inpDic['email'] if inpDic and inpDic['email'] else ""
    
    if not email:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: Email Invalid"
        )
    
    return await playlist.AddToPlaylistService(playlistId,songs,email)

class gsModel(BaseModel):
    email:str
    id:str


@router.post("/getSongsPlayList")
async def getSongs(data: gsModel):
    dataDict = data.dict(by_alias=True)
    email = dataDict['email']
    idp = dataDict['id']

    User = await user_collection.find_one({'email': email.lower()})
    if not User:
        print("user Not Found!!",email)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    playlists = User['playlist'] if User.get('playlist') else []
    
    if not playlists:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error: No Data Fetched"
        )
    found=False
    songs = []
    for pl in playlists:
        if pl['id'] == idp:
            found=True  # id Used here 
            songs = pl.get('songs', [])  
            break
    
    if not found:
        print("songs Not Found!!",pl)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No songs found in the playlist"
        )
    
    return {"status_code": status.HTTP_200_OK, "songs": songs}



@router.post("/isLiked")
async def chLike(data: gsModel):
    dataDict = data.dict(by_alias=True)
    email = dataDict['email']
    playlist_id = dataDict['id']

    user = await user_collection.find_one({"email": email.lower()})

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    playlists = user.get("playlist", [])

    playlist_found = False
    for pl in playlists:
        if pl['id'] == playlist_id:  # id Used Here
            return pl
    
    raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    
@router.post("/changeLike")
async def chLike(data: gsModel):

    dataDict = data.dict(by_alias=True)
    email = dataDict['email']
    playlist_id = dataDict['id']

    user = await user_collection.find_one({"email": email.lower()})

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    playlists = user.get("playlist", [])

    playlist_found = False
    for pl in playlists:
        if pl['id'] == playlist_id:  # id Used Here
            pl['isLiked'] = not pl['isLiked']
            playlist_found = True
            break

    if not playlist_found:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Playlist not found"
        )

    update_result = await user_collection.update_one(
        {"email": email.lower()},
        {"$set": {"playlist": playlists}} 
    )

    if update_result.modified_count == 0:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update playlist"
        )

    return {
        "status_code": status.HTTP_200_OK,
        "message": "Playlist like status updated successfully",
        "playlist": playlists
    }

@router.get('/getAllPlaylists') 
async def get_all_playlists(email: str = Query(..., description="User email to fetch playlists")):
    print(email)
    User = await user_collection.find_one({'email': email.lower()})
    if not User:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    playlists = User['playlist'] if User.get('playlist') else []
    return {
        'playlist':playlists,
        "status_code": status.HTTP_200_OK,
        "message": "Playlist fetched successfully",
    }
    

