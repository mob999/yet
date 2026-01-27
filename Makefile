.PHONY: docker-up server-generate server-start flutter-run clean help

# Default target
help:
	@echo "Available commands:"
	@echo "  make docker-up       - Start Docker containers (DB + Redis)"
	@echo "  make server-generate - Run 'serverpod generate' in server directory"
	@echo "  make server-start    - Start the backend server with migrations"
	@echo "  make flutter-run     - Run the Flutter app"
	@echo "  make clean           - Clean build artifacts and get dependencies"

docker-up:
	cd yet_server && docker compose up --build --detach

server-generate:
	# Uses the locally activated serverpod executable if in PATH, or falls back to pub
	cd yet_server && serverpod generate

server-start:
	cd yet_server && dart bin/main.dart --apply-migrations

flutter-run:
	cd yet_flutter && flutter run

clean:
	cd yet_server && rm -rf .dart_tool pubspec.lock && dart pub get
	cd yet_client && rm -rf .dart_tool pubspec.lock && dart pub get
	cd yet_flutter && rm -rf .dart_tool pubspec.lock && flutter pub get
