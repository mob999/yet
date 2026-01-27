# Yet? (练了吗)

A Serverpod + Flutter application for sharing status with family and friends.

## Project Structure
- `yet_server`: Backend (Dart + Serverpod)
- `yet_client`: Generated Client Library
- `yet_flutter`: Frontend Mobile App

## 🚀 Quick Start

### 1. Prerequisites
- Docker (running)
- Flutter SDK
- Serverpod CLI

### 2. Setup Environment
**Fixing `serverpod: command not found`**:
Add the Dart Pub cache bin to your PATH. Add this line to your `~/.zshrc` or `~/.bashrc`:

```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

Then run `source ~/.zshrc` (or restart terminal).

### 3. Usage (Makefile)

We have included a `Makefile` for common tasks:

| Command | Description |
|---------|-------------|
| `make docker-up` | Starts Postgres & Redis containers |
| `make server-generate` | Regenerates Serverpod code (run after editing models/endpoints) |
| `make server-start` | Starts the backend server on http://localhost:8080 |
| `make flutter-run` | Launch the mobile app |

### Manual Commands
If you don't have `make` installed:

**Start Database:**
```bash
cd yet_server
docker compose up --build --detach
```

**Generate Code:**
```bash
cd yet_server
serverpod generate
```

**Run Server:**
```bash
cd yet_server
dart bin/main.dart --apply-migrations
```
