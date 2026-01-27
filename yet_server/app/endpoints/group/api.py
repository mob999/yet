
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ...database import get_db
from ...endpoints.user.api import get_current_user
from ...exceptions import BusinessError, NotFoundError
from ...models import User
from . import schemas, service

router = APIRouter()

@router.post("/", response_model=schemas.Group)
async def create_group(
    group_in: schemas.GroupCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await service.create_group(db, group_in, creator_id=current_user.id)

@router.post("/join", response_model=schemas.Group)
async def join_group(
    join_in: schemas.GroupJoin,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    group, error = await service.join_group(db, user_id=current_user.id, invite_code=join_in.invite_code)
    if error:
        if error == "Invalid invite code":
            raise NotFoundError(error)
        raise BusinessError(error)
    return group

@router.get("/me", response_model=list[schemas.Group])
async def get_my_groups(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await service.get_user_groups(db, user_id=current_user.id)
