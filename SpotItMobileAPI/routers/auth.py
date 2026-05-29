from datetime import datetime, timedelta
import bcrypt
import jwt
from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from database import db
from models import LoginRequest, SignupRequest, User, TokenResponse
from config import SECRET_KEY, ALGORITHM

# this is from pokedexAPI I am repurposing it

router = APIRouter()
security = HTTPBearer(auto_error=False)

# bcrypt has a 72-byte limit; use first 72 bytes to avoid ValueError
MAX_BCRYPT_BYTES = 72


def hash_password(password: str) -> str:
    raw = password.encode("utf-8")[:MAX_BCRYPT_BYTES]
    return bcrypt.hashpw(raw, bcrypt.gensalt()).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    raw = plain.encode("utf-8")[:MAX_BCRYPT_BYTES]
    return bcrypt.checkpw(raw, hashed.encode("utf-8"))


def create_access_token(user_id: int) -> str:
    expire = datetime.utcnow() + timedelta(days=30)
    return jwt.encode(
        {"sub": str(user_id), "exp": expire},
        SECRET_KEY,
        algorithm=ALGORITHM,
    )


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(security),
) -> User:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id_str = payload.get("sub")
        if user_id_str is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        user_id = int(user_id_str)
    except (jwt.PyJWTError, ValueError):
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    users = await db.get("users") or []
    user = next((u for u in users if u.get("id") == user_id), None)
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    return User(id=user["id"], username=user["username"])


async def get_current_user_optional(
    credentials: HTTPAuthorizationCredentials | None = Depends(security),
) -> User | None:
    if credentials is None:
        return None
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id_str = payload.get("sub")
        if user_id_str is None:
            return None
        user_id = int(user_id_str)
    except (jwt.PyJWTError, ValueError):
        return None
    users = await db.get("users") or []
    user = next((u for u in users if u.get("id") == user_id), None)
    if user is None:
        return None
    return User(id=user["id"], username=user["username"])


@router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest):
    users = await db.get("users") or []
    user = next((u for u in users if u.get("username") == request.username), None)
    if user is None or not verify_password(request.password, user["password_hash"]) or " " in user["username"]:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    token = create_access_token(user["id"])
    return TokenResponse(access_token=token, token_type="bearer", user=User(id=user["id"], username=user["username"]))


@router.post("/signup", response_model=TokenResponse)
async def register(request: SignupRequest):
    users = await db.get("users") or []
    if any(u.get("username") == request.username for u in users):
        raise HTTPException(status_code=400, detail="Username already registered")
    if " " in request.username:
        raise HTTPException(status_code=400, detail="Username cannot contain spaces")
    next_id = max((u.get("id", 0) for u in users), default=0) + 1
    user_dict = {
        "id": next_id,
        "username": request.username,
        "password_hash": hash_password(request.password),
    }
    users.append(user_dict)
    await db.set("users", users)
    user_icons = await db.get("user_icons") or {}
    user_icons[str(next_id)] = {}
    await db.set("user_icons", user_icons)
    await db.save()
    token = create_access_token(next_id)
    return TokenResponse(access_token=token, token_type="bearer", user=User(id=next_id, username=request.username))
