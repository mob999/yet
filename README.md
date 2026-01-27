# Yet? (练了吗)

A FastAPI + Flutter application for sharing status with family and friends.

## Project Structure
- `yet_server`: Backend (Python + FastAPI + SQLite), managed by `uv`
- `yet_flutter`: Frontend Mobile App (Flutter)

## 🚀 Quick Start

### 1. Prerequisites
- [uv](https://github.com/astral-sh/uv) (Python package manager)
- Flutter SDK

### 2. Usage (Makefile)

We have included a `Makefile` for common tasks:

| Command | Description |
|---------|-------------|
| `make server-run` | Starts the FastAPI backend on http://localhost:8000 |
| `make flutter-run` | Launch the mobile app |
| `make flutter-gen` | Generate Flutter API client from Backend Swagger spec |

### Manual Commands
If you don't have `make` installed:

**Run Server:**
```bash
cd yet_server
uv run uvicorn app.main:app --reload
```

**Generate Flutter API Client:**
```bash
cd yet_flutter
flutter pub run swagger_parser:generate
```

**Run Flutter App:**
```bash
cd yet_flutter
flutter run
```
