import json
from datetime import datetime
from enum import Enum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, field_validator


class ActionInputType(str, Enum):
    NUMBER = "number"
    TEXT = "text"
    IMAGE = "image"


class ActionInputField(BaseModel):
    key: str
    label: str
    type: ActionInputType


class ActionDefinitionBase(BaseModel):
    name: str
    icon_url: str | None = None
    input_schema: list[ActionInputField] = Field(default_factory=list)

    @field_validator("input_schema", mode="before")
    @classmethod
    def parse_input_schema(cls, v):
        if isinstance(v, str):
            try:
                return json.loads(v)
            except json.JSONDecodeError:
                return []
        return v


class ActionDefinitionCreate(ActionDefinitionBase):
    target_group_ids: list[int] = Field(default_factory=list)


class ActionDefinitionUpdate(BaseModel):
    name: str | None = None
    icon_url: str | None = None
    input_schema: list[dict[str, Any]] | None = None
    target_group_ids: list[int] | None = None


class ActionDefinition(ActionDefinitionBase):
    id: int
    creator_id: int
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class ActionRecordBase(BaseModel):
    input_data: dict[str, Any] = Field(default_factory=dict)
    occurred_at: datetime = Field(default_factory=datetime.now)

    @field_validator("input_data", mode="before")
    @classmethod
    def parse_input_data(cls, v):
        if isinstance(v, str):
            try:
                return json.loads(v)
            except json.JSONDecodeError:
                return {}
        return v


class ActionRecordCreate(ActionRecordBase):
    definition_id: int
    # group_id is removed, derived from broadcast targets


class ActionRecord(ActionRecordBase):
    id: int
    user_id: int
    group_id: int
    definition_id: int
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None
    
    # Optional nested definition for convenience - Disabled to avoid async lazy load issues for now
    # definition: ActionDefinition | None = None

    model_config = ConfigDict(from_attributes=True)
