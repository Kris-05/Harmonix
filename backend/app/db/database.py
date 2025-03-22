
from bson import ObjectId
from motor.motor_asyncio import AsyncIOMotorClient
from app.schema.User import UserModel
from app.utils.utils import hash_password


MONGO_URI = "mongodb://localhost:27017"

# Create MongoDB Client
client = AsyncIOMotorClient(MONGO_URI)

# Access the database (replace 'mydatabase' with your DB name)
database = client['Harmonix']

# Access a collection (replace 'mycollection' with your collection name)
collection = database['Users']

user_collection = database['Users']  # Updated to 'Users'


#indexess.....
async def init_db():
    await user_collection.create_index("email", unique=True)