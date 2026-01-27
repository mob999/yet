import random
import string

from loguru import logger
from sqlalchemy.ext.asyncio import AsyncSession

from ... import models
from . import schemas


def generate_invite_code(length: int = 8) -> str:
    """Generate a random alphanumeric invite code."""
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choice(chars) for _ in range(length))

async def create_group(db: AsyncSession, group_in: schemas.GroupCreate, creator_id: int):
    from sqlalchemy import select
    # Ensure unique invite code
    invite_code = generate_invite_code()
    while (await db.execute(select(models.Group).filter(models.Group.invite_code == invite_code))).scalars().first():
        invite_code = generate_invite_code()
    
    db_group = models.Group(
        name=group_in.name,
        invite_code=invite_code,
        creator_id=creator_id
    )
    db.add(db_group)
    await db.commit()
    await db.refresh(db_group)
    
    # Creator automatically becomes a member
    member = models.GroupMember(
        user_id=creator_id,
        group_id=db_group.id
    )
    db.add(member)
    await db.commit()
    
    logger.info(f"Group created: {db_group.name} (id={db_group.id}) by user_id: {creator_id}")
    return db_group

async def join_group(db: AsyncSession, user_id: int, invite_code: str):
    from sqlalchemy import select
    result = await db.execute(select(models.Group).filter(
        models.Group.invite_code == invite_code,
        models.Group.deleted_at.is_(None)
    ))
    group = result.scalars().first()
    
    if not group:
        return None, "Invalid invite code"
    
    # Check if already a member
    result = await db.execute(select(models.GroupMember).filter(
        models.GroupMember.user_id == user_id,
        models.GroupMember.group_id == group.id,
        models.GroupMember.deleted_at.is_(None)
    ))
    existing_member = result.scalars().first()
    
    if existing_member:
        return group, "Already a member"
    
    member = models.GroupMember(
        user_id=user_id,
        group_id=group.id
    )
    db.add(member)
    await db.commit()
    
    logger.info(f"User {user_id} joined group {group.id}")
    return group, None

async def get_user_groups(db: AsyncSession, user_id: int):
    from sqlalchemy import select
    result = await db.execute(select(models.Group).join(models.GroupMember).filter(
        models.GroupMember.user_id == user_id,
        models.GroupMember.deleted_at.is_(None),
        models.Group.deleted_at.is_(None)
    ))
    return result.scalars().all()
