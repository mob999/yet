from loguru import logger
from sqlalchemy.orm import Session

from ... import models, security
from . import schemas


def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def create_user(db: Session, user_in: schemas.UserCreate):
    hashed_password = security.get_password_hash(user_in.password)
    new_user = models.User(email=user_in.email, hashed_password=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Create empty profile for the user
    new_profile = models.UserProfile(user_id=new_user.id)
    db.add(new_profile)
    db.commit()
    
    logger.info(f"New user registered: {new_user.email} (id={new_user.id})")
    return new_user

def authenticate_user(db: Session, email: str, password: str):
    user = get_user_by_email(db, email)
    if not user or not security.verify_password(password, user.hashed_password):
        logger.warning(f"Failed login attempt for email: {email}")
        return None
    logger.info(f"User authenticated: {email}")
    return user
