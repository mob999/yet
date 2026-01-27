.PHONY: server-run flutter-run flutter-gen clean help

# Default target
help:
	@echo "Available commands:"
	@echo "  make server-run      - Run the FastAPI backend using uv"
	@echo "  make flutter-run     - Run the Flutter app"
	@echo "  make flutter-gen     - Generate Flutter API client from Swagger"
	@echo "  make clean           - Clean build artifacts and get dependencies"

server-run:
	cd yet_server && uv run uvicorn app.main:app --reload

flutter-run:
	cd yet_flutter && flutter run

flutter-gen:
	cd yet_flutter && flutter pub run swagger_parser:generate

clean:
	cd yet_server && rm -rf .venv uv.lock
	cd yet_flutter && rm -rf .dart_tool pubspec.lock && flutter pub get
