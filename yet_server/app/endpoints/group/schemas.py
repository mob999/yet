from datetime import datetime

from pydantic import BaseModel, ConfigDict


class GroupBase(BaseModel):
    name: str

class GroupCreate(GroupBase):
    pass

class Group(GroupBase):
    id: int
    invite_code: str
    creator_id: int
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)

class GroupJoin(BaseModel):
    invite_code: str

class GroupMember(BaseModel):
    user_id: int
    group_id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
