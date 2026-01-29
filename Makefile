.PHONY: server-run server-lint server-test flutter-run flutter-gen clean help

# Default target
help:
	@echo "Available commands:"
	@echo "  make server-run      - Run the FastAPI backend using uv"
	@echo "  make server-lint     - Check and fix backend code style using ruff"
	@echo "  make server-test     - Run backend tests using pytest"
	@echo "  make flutter-run     - Run the Flutter app"
	@echo "  make flutter-gen     - Generate Flutter API client from Swagger"
	@echo "  make clean           - Clean build artifacts and get dependencies"

server-run:
	cd yet_server && uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

server-lint:
	cd yet_server && uv run ruff check --fix

server-test:
	cd yet_server && uv run pytest

db-migrate:
	cd yet_server && uv run alembic revision --autogenerate -m "$(msg)"

db-upgrade:
	cd yet_server && uv run alembic upgrade head

flutter-run:
	cd yet_flutter && flutter run

flutter-gen:
	cd yet_server && uv run python export_openapi.py
	cd yet_flutter && dart run swagger_parser
	cd yet_flutter && dart run build_runner build --delete-conflicting-outputs

clean:
	cd yet_server && rm -rf .venv uv.lock
	cd yet_flutter && rm -rf .dart_tool pubspec.lock && flutter pub get
