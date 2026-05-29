from contextlib import asynccontextmanager
from fastapi import FastAPI
from pickledb import PickleDB


db = PickleDB('spotItDatabase.db')

@asynccontextmanager
async def lifespan(app: FastAPI):
    await db.load()
    if await db.get("users") is None:
        await db.set("users", [])
    if await db.get("leaderboard") is None:
        await db.set("leaderboard", [])
    if await db.get("user_icons") is None:
        await db.get("user_icons", {})
    yield
    await db.save()
    print("Database saved")
