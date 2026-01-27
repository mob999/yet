from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ...database import get_db
from ...endpoints.user.api import get_current_user
from ...models import User
from ...exceptions import BusinessError, NotFoundError
from . import schemas, service

router = APIRouter()

@router.post("/", response_model=schemas.Group)
def create_group(
    group_in: schemas.GroupCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return service.create_group(db, group_in, creator_id=current_user.id)

@router.post("/join", response_model=schemas.Group)
def join_group(
    join_in: schemas.GroupJoin,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    group, error = service.join_group(db, user_id=current_user.id, invite_code=join_in.invite_code)
    if error:
        if error == "Invalid invite code":
            raise NotFoundError(error)
        raise BusinessError(error)
    return group

@router.get("/me", response_model=List[schemas.Group])
def get_my_groups(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return service.get_user_groups(db, user_id=current_user.id)
