from pathlib import Path

from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import FileResponse
from database import db
from models import StatEntry, Icons, User, StoreStatRequest
from routers.auth import get_current_user, get_current_user_optional
from fastapi.responses import JSONResponse

router = APIRouter()

@router.get("/leaderboard", response_model=list[StatEntry])
async def get_leaderboard():
    leaderboard = await db.get("leaderboard") or []
    return sorted(leaderboard, key=lambda x: x["time"])

@router.post("/leaderboard", response_model=StatEntry)
@router.put("/leaderboard", response_model=StatEntry)
async def add_stat(statRequest: StoreStatRequest, current_user: User = Depends(get_current_user_optional)):
    leaderboard = await db.get("leaderboard") or []
    username = current_user.username if current_user else "Unknown User"
    new_entry = {"id": len(leaderboard) + 1, "username": username, "time": statRequest.time}
    leaderboard.append(new_entry)
    await db.set("leaderboard", leaderboard)
    await db.save()
    return new_entry

@router.get("/userIcons", response_model=dict[int, str])
async def get_user_icons(current_user: User = Depends(get_current_user)): # returns the current users icons
    icons = await db.get("user_icons") or {}
    users_icons = icons.get(str(current_user.id), {})
    return users_icons


@router.post("/userIcons", response_model=dict[int, str])
@router.put("/userIcons", response_model=dict[int, str])
async def change_user_icons(icons: Icons, current_user: User = Depends(get_current_user)):
    user_icons = await db.get("user_icons") or {}
    new_icons = {}
    for key, value in icons.model_dump()["icons"].items():
        new_icons[str(key)] = value
    user_icons[str(current_user.id)] = new_icons
    await db.set("user_icons", user_icons)
    await db.save()
    return user_icons[str(current_user.id)] # return the users saved icons 