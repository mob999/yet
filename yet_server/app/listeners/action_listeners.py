from ..events.action_events import ActionCreatedEvent
from ..events.bus import listen
from ..logger import logger


@listen(ActionCreatedEvent)
async def log_action_created(event: ActionCreatedEvent):
    logger.info(f"[Listener] Action Created: User {event.user_id} -> {len(event.record_ids)} Records (Def {event.definition_id})")
    logger.debug(f"Target Groups: {event.target_group_ids}")
    logger.debug(f"Input Data: {event.input_data}")
