from .bus import Event


class ActionCreatedEvent(Event):
    def __init__(self, record_ids: list[int], user_id: int, definition_id: int, input_data: str, target_group_ids: list[int]):
        self.record_ids = record_ids
        self.user_id = user_id
        self.definition_id = definition_id
        self.input_data = input_data
        self.target_group_ids = target_group_ids
