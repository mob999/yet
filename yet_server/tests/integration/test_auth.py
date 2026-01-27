import pytest


@pytest.mark.asyncio
async def test_user_registration(client):
    response = await client.post(
        "/users/register",
        json={"email": "test@example.com", "password": "password123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data

@pytest.mark.asyncio
async def test_user_registration_duplicate_email(client):
    # First registration
    await client.post(
        "/users/register",
        json={"email": "test@example.com", "password": "password123"}
    )
    # Duplicate registration
    response = await client.post(
        "/users/register",
        json={"email": "test@example.com", "password": "password123"}
    )
    assert response.status_code == 400
    assert response.json()["message"] == "Email already registered"

@pytest.mark.asyncio
async def test_user_login(client):
    # Register user
    await client.post(
        "/users/register",
        json={"email": "test@example.com", "password": "password123"}
    )
    # Login
    response = await client.post(
        "/users/login",
        data={"username": "test@example.com", "password": "password123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

@pytest.mark.asyncio
async def test_user_login_wrong_password(client):
    await client.post(
        "/users/register",
        json={"email": "test@example.com", "password": "password123"}
    )
    response = await client.post(
        "/users/login",
        data={"username": "test@example.com", "password": "wrongpassword"}
    )
    assert response.status_code == 401
    assert response.json()["message"] == "Incorrect email or password"

@pytest.mark.asyncio
async def test_get_me(client):
    # Register and login
    await client.post(
        "/users/register",
        json={"email": "test@example.com", "password": "password123"}
    )
    login_response = await client.post(
        "/users/login",
        data={"username": "test@example.com", "password": "password123"}
    )
    token = login_response.json()["access_token"]
    
    # Get me
    response = await client.get(
        "/users/me",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    assert response.json()["email"] == "test@example.com"
