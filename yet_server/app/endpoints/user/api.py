from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from sqlalchemy.ext.asyncio import AsyncSession

from ... import models, security
from ...config import settings
from ...database import get_db
from ...exceptions import AuthenticationError, BusinessError
from . import schemas, service

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="users/login")

async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)):
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str | None = payload.get("sub")
        if email is None:
            raise AuthenticationError("Could not validate credentials")
        token_data = schemas.TokenData(email=email)
    except JWTError:
        raise AuthenticationError("Could not validate credentials")
    user = await service.get_user_by_email(db, email=token_data.email)
    if user is None:
        raise AuthenticationError("User not found")
    return user

@router.post("/register", response_model=schemas.User)
async def register(user_in: schemas.UserCreate, db: AsyncSession = Depends(get_db)):
    db_user = await service.get_user_by_email(db, email=user_in.email)
    if db_user:
        raise BusinessError("Email already registered")
    return await service.create_user(db, user_in)

@router.post("/login", response_model=schemas.Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(get_db)):
    user = await service.authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise AuthenticationError("Incorrect email or password")
    
    access_token = security.create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=schemas.User)
async def read_users_me(current_user: models.User = Depends(get_current_user)):
    return current_user

@router.put("/me/profile", response_model=schemas.UserProfile)
async def update_my_profile(
    profile_in: schemas.UserProfileUpdate,
    current_user: models.User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    return await service.update_user_profile(db, user_id=current_user.id, profile_in=profile_in)
