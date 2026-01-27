import random
import string
from sqlalchemy.orm import Session
from loguru import logger
from ... import models
from . import schemas

def generate_invite_code(length: int = 8) -> str:
    """Generate a random alphanumeric invite code."""
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choice(chars) for _ in range(length))

def create_group(db: Session, group_in: schemas.GroupCreate, creator_id: int):
    # Ensure unique invite code
    invite_code = generate_invite_code()
    while db.query(models.Group).filter(models.Group.invite_code == invite_code).first():
        invite_code = generate_invite_code()
    
    db_group = models.Group(
        name=group_in.name,
        invite_code=invite_code,
        creator_id=creator_id
    )
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    
    # Creator automatically becomes a member
    member = models.GroupMember(
        user_id=creator_id,
        group_id=db_group.id
    )
    db.add(member)
    db.commit()
    
    logger.info(f"Group created: {db_group.name} (id={db_group.id}) by user_id: {creator_id}")
    return db_group

def join_group(db: Session, user_id: int, invite_code: str):
    group = db.query(models.Group).filter(
        models.Group.invite_code == invite_code,
        models.Group.deleted_at == None
    ).first()
    
    if not group:
        return None, "Invalid invite code"
    
    # Check if already a member
    existing_member = db.query(models.GroupMember).filter(
        models.GroupMember.user_id == user_id,
        models.GroupMember.group_id == group.id,
        models.GroupMember.deleted_at == None
    ).first()
    
    if existing_member:
        return group, "Already a member"
    
    member = models.GroupMember(
        user_id=user_id,
        group_id=group.id
    )
    db.add(member)
    db.commit()
    
    logger.info(f"User {user_id} joined group {group.id}")
    return group, None

def get_user_groups(db: Session, user_id: int):
    return db.query(models.Group).join(models.GroupMember).filter(
        models.GroupMember.user_id == user_id,
        models.GroupMember.deleted_at == None,
        models.Group.deleted_at == None
    ).all()
