import asyncio
from collections.abc import Awaitable, Callable

from loguru import logger


# Base Event Class
class Event:
    pass

# Type for event handlers
EventHandler = Callable[[Event], Awaitable[None]]

class EventBus:
    _subscribers: dict[type[Event], list[EventHandler]] = {}
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._subscribers = {}
        return cls._instance

    @classmethod
    def subscribe(cls, event_type: type[Event], handler: EventHandler):
        """Register a new handler for a specific event type."""
        if event_type not in cls._subscribers:
            cls._subscribers[event_type] = []
        cls._subscribers[event_type].append(handler)
        logger.debug(f"Subscribed {handler.__name__} to {event_type.__name__}")

    @classmethod
    async def publish(cls, event: Event):
        """Publish an event to all subscribers asynchronously."""
        event_type = type(event)
        if event_type in cls._subscribers:
            handlers = cls._subscribers[event_type]
            logger.debug(f"Publishing {event_type.__name__} to {len(handlers)} handlers")
            for handler in handlers:
                # Fire and forget / Background execution
                # We use asyncio.create_task to run handlers concurrently without blocking the publisher
                try:
                    asyncio.create_task(cls._run_handler(handler, event))
                except Exception as e:
                    logger.error(f"Failed to schedule handler {handler.__name__} for {event_type.__name__}: {e}")
        else:
            logger.debug(f"No subscribers for {event_type.__name__}")

    @staticmethod
    async def _run_handler(handler: EventHandler, event: Event):
        try:
            await handler(event)
        except Exception as e:
            logger.error(f"Error in event handler {handler.__name__}: {e}")

# Global Event Bus Instance
event_bus = EventBus()

# Decorator for registering listeners
def listen(event_type: type[Event]):
    """Decorator to register an async function as an event listener."""
    def decorator(func: EventHandler):
        event_bus.subscribe(event_type, func)
        return func
    return decorator
