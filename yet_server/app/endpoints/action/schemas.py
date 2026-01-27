import json
from datetime import datetime
from typing import Any, List

from pydantic import BaseModel, ConfigDict, Field, field_validator


class ActionDefinitionBase(BaseModel):
    name: str
    icon_url: str | None = None
    input_schema: List[dict[str, Any]] = Field(default_factory=list)

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
    pass


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
    group_id: int


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
