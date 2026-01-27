
def test_update_user_profile(client):
    # Register and login
    client.post(
        "/users/register",
        json={"email": "profile@example.com", "password": "password123"}
    )
    login_response = client.post(
        "/users/login",
        data={"username": "profile@example.com", "password": "password123"}
    )
    token = login_response.json()["access_token"]
    
    # Update profile
    new_data = {
        "avatar_url": "https://example.com/avatar.png",
        "gender": "male",
        "birth_date": "1990-01-01T00:00:00"
    }
    response = client.put(
        "/users/me/profile",
        json=new_data,
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["avatar_url"] == "https://example.com/avatar.png"
    assert data["gender"] == "male"
    assert "1990-01-01" in data["birth_date"]

def test_update_profile_unauthorized(client):
    response = client.put(
        "/users/me/profile",
        json={"gender": "female"}
    )
    assert response.status_code == 401
