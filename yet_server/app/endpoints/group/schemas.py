from datetime import datetime

from pydantic import BaseModel


class GroupBase(BaseModel):
    name: str

class GroupCreate(GroupBase):
    pass

class Group(GroupBase):
    id: int
    invite_code: str
    creator_id: int
    created_at: datetime

    class Config:
        from_attributes = True
