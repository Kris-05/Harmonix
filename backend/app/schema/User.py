from typing import List, Optional
from pydantic import GetCoreSchemaHandler,BaseModel,Field
from pydantic_core import core_schema
from bson import ObjectId

class PyObjectId(str):
    @classmethod
    def __get_pydantic_core_schema__(cls, source_type, handler: GetCoreSchemaHandler):
        return core_schema.no_info_after_validator_function(cls.validate, core_schema.str_schema())

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return str(v)
# User Model for MongoDB
# chaange this incase of the change for the schema of the Doc....
# the filed in the db

# Song Model
class SongModel(BaseModel):
    id: str
    name: str

# Playlist Model
class PlaylistModel(BaseModel):
    name:str
    id:str
    owner: str
    isLiked:bool
    isPinned:bool
    songs: List[SongModel] = []



class UserModel(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    name: str
    email: str
    password: str
    gender: str
    preferred_languages: List[str] = []
    artists: Optional[List[str]] = [] 
    playlist: Optional[List[PlaylistModel]] = []

    class Config:
        populate_by_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}