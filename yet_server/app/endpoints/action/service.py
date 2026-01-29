import json

from loguru import logger
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ... import models
from . import schemas


async def create_action_definition(db: AsyncSession, definition_in: schemas.ActionDefinitionCreate, creator_id: int):
    # Serialize schema to string for storage
    schema_str = json.dumps([item.model_dump() for item in definition_in.input_schema])
    
    db_definition = models.ActionDefinition(
        name=definition_in.name,
        icon_url=definition_in.icon_url,
        input_schema=schema_str,
        creator_id=creator_id
    )
    db.add(db_definition)
    await db.commit()
    await db.refresh(db_definition)
    
    # Create broadcast targets
    if definition_in.target_group_ids:
        for gid in definition_in.target_group_ids:
            target = models.GroupActionDefinition(
                group_id=gid,
                definition_id=db_definition.id
            )
            db.add(target)
        await db.commit()

    logger.info(f"Action Definition created: {db_definition.name} (id={db_definition.id}) with targets: {definition_in.target_group_ids}")
    return db_definition

async def update_action_definition(db: AsyncSession, definition_id: int, definition_in: schemas.ActionDefinitionUpdate):
    result = await db.execute(select(models.ActionDefinition).filter(models.ActionDefinition.id == definition_id))
    db_definition = result.scalar_one_or_none()
    
    if not db_definition:
        return None
        
    if definition_in.name is not None:
        db_definition.name = definition_in.name
    if definition_in.icon_url is not None:
        db_definition.icon_url = definition_in.icon_url
    if definition_in.input_schema is not None:
        db_definition.input_schema = json.dumps([item.model_dump() for item in definition_in.input_schema])

    # Update broadcast targets if provided
    if definition_in.target_group_ids is not None:
        # Delete existing
        await db.execute(
            models.GroupActionDefinition.__table__.delete().where(
                models.GroupActionDefinition.definition_id == definition_id
            )
        )
        # Add new
        for gid in definition_in.target_group_ids:
            target = models.GroupActionDefinition(
                group_id=gid,
                definition_id=definition_id
            )
            db.add(target)

    await db.commit()
    await db.refresh(db_definition)
    logger.info(f"Action Definition updated: {db_definition.name} (id={db_definition.id})")
    
    return db_definition

async def get_action_definitions(db: AsyncSession):
    # For now, return all definitions. Later we might filter by visibility.
    result = await db.execute(select(models.ActionDefinition).filter(models.ActionDefinition.deleted_at.is_(None)))
    return result.scalars().all()

async def create_action_record(db: AsyncSession, record_in: schemas.ActionRecordCreate, user_id: int):
    # Serialize data to string for storage
    data_str = json.dumps(record_in.input_data)
    
    # Get Broadcast Targets
    result = await db.execute(
        select(models.GroupActionDefinition)
        .filter(models.GroupActionDefinition.definition_id == record_in.definition_id, models.GroupActionDefinition.deleted_at.is_(None))
    )
    targets = result.scalars().all()
    
    records = []
    if not targets:
        logger.warning(f"No broadcast targets found for definition {record_in.definition_id}. Action not recorded.")
        # Return empty list as per contract
        pass
    else:
        for target in targets:
            db_record = models.ActionRecord(
                user_id=user_id,
                group_id=target.group_id,
                definition_id=record_in.definition_id,
                input_data=data_str,
                occurred_at=record_in.occurred_at
            )
            db.add(db_record)
            records.append(db_record)
        
        await db.commit()
        for r in records:
            await db.refresh(r)
        
        logger.info(f"Action Record broadcast to {len(records)} groups for user {user_id} on definition {record_in.definition_id}")

    return records

async def get_user_records(db: AsyncSession, user_id: int):
    # Return my records, ordered by occurred_at desc
    result = await db.execute(
        select(models.ActionRecord)
        .filter(models.ActionRecord.user_id == user_id, models.ActionRecord.deleted_at.is_(None))
        .order_by(models.ActionRecord.occurred_at.desc())
    )
    return result.scalars().all()
