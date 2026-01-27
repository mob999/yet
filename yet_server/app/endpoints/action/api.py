
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ...database import get_db
from ...endpoints.user.api import get_current_user
from ...models import User
from . import schemas, service

router = APIRouter()

@router.post("/definitions", response_model=schemas.ActionDefinition)
async def create_definition(
    definition_in: schemas.ActionDefinitionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await service.create_action_definition(db, definition_in, creator_id=current_user.id)

@router.get("/definitions", response_model=list[schemas.ActionDefinition])
async def get_definitions(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await service.get_action_definitions(db)

@router.post("/records", response_model=schemas.ActionRecord)
async def create_record(
    record_in: schemas.ActionRecordCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await service.create_action_record(db, record_in, user_id=current_user.id)

@router.get("/records", response_model=list[schemas.ActionRecord])
async def get_my_records(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return await service.get_user_records(db, user_id=current_user.id)
