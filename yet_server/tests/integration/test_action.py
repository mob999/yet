import pytest


@pytest.mark.asyncio
async def test_create_action_definition(client):
    # Register and login
    await client.post(
        "/users/register",
        json={"email": "action_creator@example.com", "password": "password123"}
    )
    login_response = await client.post(
        "/users/login",
        data={"username": "action_creator@example.com", "password": "password123"}
    )
    token = login_response.json()["access_token"]
    
    # Create definition
    response = await client.post(
        "/actions/definitions",
        json={
            "name": "Gym Workout",
            "icon_url": "gym.png",
            "input_schema": [
                {"key": "duration", "label": "Duration (mins)", "type": "number"},
                {"key": "notes", "label": "Notes", "type": "text"}
            ]
        },
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Gym Workout"
    assert len(data["input_schema"]) == 2
    assert data["input_schema"][0]["key"] == "duration"

@pytest.mark.asyncio
async def test_update_action_definition(client):
    # Setup
    await client.post("/users/register", json={"email": "updater@example.com", "password": "p"})
    token = (await client.post("/users/login", data={"username": "updater@example.com", "password": "p"})).json()["access_token"]
    
    # Group A
    gid_a = (await client.post("/groups/", json={"name": "A"}, headers={"Authorization": f"Bearer {token}"})).json()["id"]
    # Group B
    gid_b = (await client.post("/groups/", json={"name": "B"}, headers={"Authorization": f"Bearer {token}"})).json()["id"]

    # Create def with target A
    def_data = await client.post(
        "/actions/definitions", 
        json={"name": "Sleep", "target_group_ids": [gid_a]},
        headers={"Authorization": f"Bearer {token}"}
    )
    def_id = def_data.json()["id"]

    # Execute to verify broadcast to A
    rec_res = await client.post(
        "/actions/records",
        json={"definition_id": def_id, "input_data": {}},
        headers={"Authorization": f"Bearer {token}"}
    )
    assert len(rec_res.json()) == 1
    assert rec_res.json()[0]["group_id"] == gid_a
    
    # Update def: change name, target B (remove A)
    update_res = await client.put(
        f"/actions/definitions/{def_id}",
        json={"name": "Deep Sleep", "target_group_ids": [gid_b]},
        headers={"Authorization": f"Bearer {token}"}
    )
    assert update_res.status_code == 200
    assert update_res.json()["name"] == "Deep Sleep"
    
    # Execute again to verify broadcast to B
    rec_res_2 = await client.post(
        "/actions/records",
        json={"definition_id": def_id, "input_data": {}},
        headers={"Authorization": f"Bearer {token}"}
    )
    rec_data = rec_res_2.json()
    assert len(rec_data) == 1
    assert rec_data[0]["group_id"] == gid_b

@pytest.mark.asyncio
async def test_create_action_record(client):
    # 1. Create user and login
    await client.post(
        "/users/register",
        json={"email": "recorder@example.com", "password": "password123"}
    )
    login_res = await client.post(
        "/users/login",
        data={"username": "recorder@example.com", "password": "password123"}
    )
    token = login_res.json()["access_token"]
    
    # 2. Create Group
    group_res = await client.post(
        "/groups/",
        json={"name": "Action Group"},
        headers={"Authorization": f"Bearer {token}"}
    )
    group_id = group_res.json()["id"]

    # 3. Create definition
    def_res = await client.post(
        "/actions/definitions",
        json={
            "name": "Water",
            "input_schema": [{"key": "volume", "label": "Volume", "type": "number"}],
            "target_group_ids": [group_id]
        },
        headers={"Authorization": f"Bearer {token}"}
    )
    def_id = def_res.json()["id"]
    
    # 4. Create record
    response = await client.post(
        "/actions/records",
        json={
            "definition_id": def_id,
            "group_id": group_id,
            "input_data": {"volume": 250},
            "occurred_at": "2023-10-27T10:00:00"
        },
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 1
    record = data[0]
    assert record["definition_id"] == def_id
    assert record["group_id"] == group_id
    assert record["input_data"]["volume"] == 250

@pytest.mark.asyncio
async def test_get_my_records(client):
    # Setup user and definition
    await client.post("/users/register", json={"email": "list@example.com", "password": "p"})
    token = (await client.post("/users/login", data={"username": "list@example.com", "password": "p"})).json()["access_token"]
    
    # Create Group
    group_res = await client.post(
        "/groups/",
        json={"name": "Action Group"},
        headers={"Authorization": f"Bearer {token}"}
    )
    group_id = group_res.json()["id"]
    
    # Create definition with target
    def_res = await client.post(
        "/actions/definitions", 
        json={"name": "Test", "target_group_ids": [group_id]}, 
        headers={"Authorization": f"Bearer {token}"}
    )
    def_id = def_res.json()["id"]
    
    # Create 2 records
    await client.post(
        "/actions/records",
        json={"definition_id": def_id, "group_id": group_id, "input_data": {"val": 1}},
        headers={"Authorization": f"Bearer {token}"}
    )
    await client.post(
        "/actions/records",
        json={"definition_id": def_id, "group_id": group_id, "input_data": {"val": 2}},
        headers={"Authorization": f"Bearer {token}"}
    )
    
    # Get records
    response = await client.get("/actions/records", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2
    assert data[0]["input_data"]["val"] == 2  # Ordered by occurred_at desc (default now)
