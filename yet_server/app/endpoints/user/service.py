from loguru import logger
from sqlalchemy.ext.asyncio import AsyncSession

from ... import models, security
from . import schemas


async def get_user_by_email(db: AsyncSession, email: str):
    from sqlalchemy import select
    result = await db.execute(select(models.User).filter(models.User.email == email))
    return result.scalars().first()

async def create_user(db: AsyncSession, user_in: schemas.UserCreate):
    hashed_password = security.get_password_hash(user_in.password)
    new_user = models.User(email=user_in.email, hashed_password=hashed_password)
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    
    # Create empty profile for the user
    new_profile = models.UserProfile(user_id=new_user.id)
    db.add(new_profile)
    await db.commit()
    
    logger.info(f"New user registered: {new_user.email} (id={new_user.id})")
    return new_user

async def authenticate_user(db: AsyncSession, email: str, password: str):
    user = await get_user_by_email(db, email)
    if not user or not security.verify_password(password, user.hashed_password):
        logger.warning(f"Failed login attempt for email: {email}")
        return None
    logger.info(f"User authenticated: {email}")
    return user

async def update_user_profile(db: AsyncSession, user_id: int, profile_in: schemas.UserProfileUpdate):
    from sqlalchemy import select
    result = await db.execute(select(models.UserProfile).filter(models.UserProfile.user_id == user_id))
    db_profile = result.scalars().first()
    if not db_profile:
        # Should not happen as profile is created on registration, but for safety:
        db_profile = models.UserProfile(user_id=user_id)
        db.add(db_profile)
    
    update_data = profile_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_profile, field, value)
    
    await db.commit()
    await db.refresh(db_profile)
    logger.info(f"User profile updated for user_id: {user_id}")
    return db_profile

