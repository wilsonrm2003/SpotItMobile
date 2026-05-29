from pydantic import BaseModel


########################################################
# Database Models
########################################################
class StatEntry(BaseModel):
    id: int
    username: str
    time: float
    
class Icons(BaseModel):
    icons: dict[int, str]

class User(BaseModel):
    id: int
    username: str

class UserInDB(User):
    password_hash: str

class StoreStatRequest(BaseModel):
    time: float

########################################################
# API Models
########################################################

class LoginRequest(BaseModel):
    username: str
    password: str

class SignupRequest(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: User
