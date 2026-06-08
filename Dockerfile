FROM python:3.13-slim

# Copy uv package manager from the official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Copy dependency definitions and source code
COPY pyproject.toml uv.lock ./
COPY ./lkr ./lkr

# Setup environment to sync dependencies effectively in a docker build
ENV UV_PROJECT_ENVIRONMENT="/usr/local/"
RUN uv sync --frozen --no-dev

# Create a non-root user and switch to it for secure execution
RUN useradd -m --no-log-init appuser
USER appuser

ENTRYPOINT ["lkr"]
