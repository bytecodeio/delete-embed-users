.PHONY: help install dev-install docs build test-offline test format clean

MODE ?= with-patch
SE_OFFLINE ?= true

# Default target: show help
help:
	@echo "Available commands:"
	@echo "  make install         - Install runtime dependencies using uv"
	@echo "  make dev-install     - Install all dependencies (including dev tools) using uv"
	@echo "  make docs            - Generate CLI documentation using Typer"
	@echo "  make build           - Build and submit Docker image to Google Cloud Build"
	@echo "  make test-offline    - Run offline test (default MODE=with-patch)"
	@echo "  make test            - Run tests using pytest"
	@echo "  make format          - Format code and run pre-commit checks"
	@echo "  make clean           - Remove temporary files and python cache"

install:
	uv sync --frozen --no-dev

dev-install:
	uv sync --frozen

docs:
	uv run typer lkr/main.py utils docs --output lkr.md

# Adjust the Image Tag below (`delete-user/cli:latest`) to match your desired structure
build:
	gcloud builds submit -t us-west1-docker.pkg.dev/looker-scale-testing/delete-embed-users-v2/delete-embed-users:latest .

test-offline:
	QUERY_ID="$(QUERY_ID)" DASHBOARD_ID="$(DASHBOARD_ID)" MODEL="$(MODEL)" SE_OFFLINE="$(SE_OFFLINE)" ./test_offline.sh $(MODE)

test:
	uv run pytest

format:
	uv run pre-commit run --all-files || true

clean:
	rm -rf .venv/
	rm -rf .pytest_cache/
	rm -rf .ruff_cache/
	rm -rf lkr.egg-info/
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.py[co]" -delete
