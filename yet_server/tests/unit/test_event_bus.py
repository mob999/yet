import asyncio

import pytest

from app.events.bus import Event, EventBus, listen


# Mock Event
class TestEvent(Event):
    def __init__(self, message: str):
        self.message = message

@pytest.mark.asyncio
async def test_event_bus_subscribe_publish():
    bus = EventBus()
    received_messages = []

    async def handler(event: TestEvent):
        received_messages.append(event.message)

    bus.subscribe(TestEvent, handler)
    
    event = TestEvent("hello")
    await bus.publish(event)
    
    # Allow some time for the async task to run
    await asyncio.sleep(0.01)
    
    assert len(received_messages) == 1
    assert received_messages[0] == "hello"

@pytest.mark.asyncio
async def test_decorator_listen():
    received_messages = []

    @listen(TestEvent)
    async def decorated_handler(event: TestEvent):
        received_messages.append(event.message)

    # Need to access the singleton instance used by the decorator
    from app.events.bus import event_bus
    
    event = TestEvent("world")
    await event_bus.publish(event)
    
    await asyncio.sleep(0.01)
    
    assert len(received_messages) >= 1
    assert "world" in received_messages
    
    # Cleanup to avoid polluting other tests if sharing singleton
    if TestEvent in event_bus._subscribers:
        event_bus._subscribers[TestEvent].remove(decorated_handler)

@pytest.mark.asyncio
async def test_error_handling():
    bus = EventBus()
    
    async def faulty_handler(event: TestEvent):
        raise ValueError("Oops")

    received_messages = []
    async def good_handler(event: TestEvent):
        received_messages.append(event.message)

    bus.subscribe(TestEvent, faulty_handler)
    bus.subscribe(TestEvent, good_handler)
    
    event = TestEvent("test error")
    
    # Should not raise exception
    await bus.publish(event)
    
    await asyncio.sleep(0.01)
    
    # Good handler should still run despite faulty handler crashing
    assert len(received_messages) == 1
    assert received_messages[0] == "test error"
