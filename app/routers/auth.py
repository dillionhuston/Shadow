from app.dependencies import get_user_service, get_jwt_handler
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.db import get_db
from app.models.user import User
from app.schemas.User import UserLogin, ChangePassword, UserSignup, UserSignupResponse, UserSignOnResponse
from app.services.user_service import UserService
from app.DatabaseOps.DatabaseRepository import DatabaseOps
import jwt
import os
from datetime import datetime

router = APIRouter(prefix="/auth")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

@router.post('/signup', response_model=UserSignupResponse)
async def signup(
    user: UserSignup,
    userservice: UserService = Depends(get_user_service),
    db: AsyncSession = Depends(get_db)):
    return await userservice.register(db, user)


@router.post('/login', response_model=UserSignOnResponse)
async def login(
    user_data: UserLogin,
    userservice: UserService = Depends(get_user_service),
    db: AsyncSession = Depends(get_db)):
    return await userservice.login(db, user_data)
   
@router.post('/logout')
async def logout(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)):

    db_ops = DatabaseOps()

    try:
        payload = jwt.decode(
            token,
            os.getenv("SECRET_KEY"),
            algorithms=[os.getenv("ALGORITHM","HS256")]
        )
        exp = payload.get("exp")
        expires_at = datetime.utcfromtimestamp(exp) if exp else datetime.utcnow()
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )

    await db_ops.blacklist_token(db, token, expires_at)
    return {"message": "Successfully logged out"}    

@router.post('/change-password')
async def change_password(
    user_password: ChangePassword,
    userservice: UserService = Depends(get_user_service),
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_jwt_handler.get_current_user)):

    return await userservice.change_password(db, user, user_password)