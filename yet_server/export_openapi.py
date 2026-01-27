import json

from app.main import app

with open("../yet_flutter/assets/openapi.json", "w") as f:
    json.dump(app.openapi(), f, indent=2)
