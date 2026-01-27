import json
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from loguru import logger

from ... import models
from . import schemas


async def create_action_definition(db: AsyncSession, definition_in: schemas.ActionDefinitionCreate, creator_id: int):
    # Serialize schema to string for storage
    schema_str = json.dumps(definition_in.input_schema)
    
    db_definition = models.ActionDefinition(
        name=definition_in.name,
        icon_url=definition_in.icon_url,
        input_schema=schema_str,
        creator_id=creator_id
    )
    db.add(db_definition)
    await db.commit()
    await db.refresh(db_definition)
    
    logger.info(f"Action Definition created: {db_definition.name} (id={db_definition.id})")
    return db_definition

async def get_action_definitions(db: AsyncSession):
    # For now, return all definitions. Later we might filter by visibility.
    result = await db.execute(select(models.ActionDefinition).filter(models.ActionDefinition.deleted_at.is_(None)))
    return result.scalars().all()

async def create_action_record(db: AsyncSession, record_in: schemas.ActionRecordCreate, user_id: int):
    # Serialize data to string for storage
    data_str = json.dumps(record_in.input_data)
    
    db_record = models.ActionRecord(
        user_id=user_id,
        definition_id=record_in.definition_id,
        input_data=data_str,
        occurred_at=record_in.occurred_at
    )
    db.add(db_record)
    await db.commit()
    await db.refresh(db_record)
    
    # Eager load definition for response
    # In async, accessing db_record.definition might trigger lazy load error if not careful
    # But since we refreshed, if we need it we might need another query or selectinload
    # For simplicity, we just return the record, main attributes are there.
    # If the schema needs definition details, we should load it.
    
    logger.info(f"Action Record created for user {user_id} on definition {record_in.definition_id}")
    return db_record

async def get_user_records(db: AsyncSession, user_id: int):
    # Return my records, ordered by occurred_at desc
    result = await db.execute(
        select(models.ActionRecord)
        .filter(models.ActionRecord.user_id == user_id, models.ActionRecord.deleted_at.is_(None))
        .order_by(models.ActionRecord.occurred_at.desc())
    )
    return result.scalars().all()
