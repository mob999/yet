def test_create_group(client):
    # Register and login
    client.post(
        "/users/register",
        json={"email": "creator@example.com", "password": "password123"}
    )
    login_response = client.post(
        "/users/login",
        data={"username": "creator@example.com", "password": "password123"}
    )
    token = login_response.json()["access_token"]
    
    # Create group
    response = client.post(
        "/groups/",
        json={"name": "Test Group"},
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Test Group"
    assert len(data["invite_code"]) == 8

def test_join_group(client):
    # 1. Creator creates group
    client.post(
        "/users/register",
        json={"email": "creator2@example.com", "password": "password123"}
    )
    login_creator = client.post(
        "/users/login",
        data={"username": "creator2@example.com", "password": "password123"}
    )
    creator_token = login_creator.json()["access_token"]
    
    create_res = client.post(
        "/groups/",
        json={"name": "Joinable Group"},
        headers={"Authorization": f"Bearer {creator_token}"}
    )
    invite_code = create_res.json()["invite_code"]
    
    # 2. Joiner joins group
    client.post(
        "/users/register",
        json={"email": "joiner@example.com", "password": "password123"}
    )
    login_joiner = client.post(
        "/users/login",
        data={"username": "joiner@example.com", "password": "password123"}
    )
    joiner_token = login_joiner.json()["access_token"]
    
    join_res = client.post(
        "/groups/join",
        json={"invite_code": invite_code},
        headers={"Authorization": f"Bearer {joiner_token}"}
    )
    assert join_res.status_code == 200
    assert join_res.json()["name"] == "Joinable Group"

def test_join_group_invalid_code(client):
    client.post(
        "/users/register",
        json={"email": "user@example.com", "password": "password123"}
    )
    login_res = client.post(
        "/users/login",
        data={"username": "user@example.com", "password": "password123"}
    )
    token = login_res.json()["access_token"]
    
    response = client.post(
        "/groups/join",
        json={"invite_code": "INVALID"},
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 404
    assert response.json()["message"] == "Invalid invite code"

def test_get_my_groups(client):
    # Register and login
    client.post(
        "/users/register",
        json={"email": "member@example.com", "password": "password123"}
    )
    login_res = client.post(
        "/users/login",
        data={"username": "member@example.com", "password": "password123"}
    )
    token = login_res.json()["access_token"]
    
    # Create 2 groups
    client.post("/groups/", json={"name": "G1"}, headers={"Authorization": f"Bearer {token}"})
    client.post("/groups/", json={"name": "G2"}, headers={"Authorization": f"Bearer {token}"})
    
    response = client.get("/groups/me", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert len(response.json()) == 2
