# lkr: Looker Load Testing & Embed User Management CLI

A CLI utility built using **Typer**, **Locust**, and the **Looker Python SDK** to execute load tests, collect embed observability metrics, and manage/cleanup Looker SSO embed users.

---

## Features

- **Debug Diagnostics**: Quickly test and verify your Looker API connection and SDK settings.
- **Load Testing**: Simulates concurrent users accessing dashboards, running queries, rendering PDFs/images, or loading cookieless embed environments.
- **Observability Server**: Hosts a local dashboard iframe server, launches automated users, tracks Looker iframe JS event timings (`loaded`, `run:start`, `run:complete`), and reports performance metrics.
- **Embed User Cleanup**: Batch deletes expired/old SSO embed users using concurrent thread pools to keep Looker instance user lists clean.

---

## Getting Started

### Prerequisites

- **Python 3.13** or higher
- **[uv](https://github.com/astral-sh/uv)** (recommended Python package installer)
- **Docker** (optional, for containerization)
- **Google Cloud SDK (`gcloud`)** (optional, if pushing to GCP Artifact Registry)

### Installation

Clone/copy the repository, navigate to the folder, and run:

```bash
# Install runtime dependencies
make install

# Install dev dependencies (pytest, pre-commit, etc.)
make dev-install
```

---

## Configuration

The CLI relies on standard Looker SDK environment variables. Create a `.env` file in the root of the project:

```env
LOOKERSDK_BASE_URL="https://your-looker-instance.com:19999"
LOOKERSDK_CLIENT_ID="your_api_client_id"
LOOKERSDK_CLIENT_SECRET="your_api_client_secret"
```

Verify your configuration by running the debug check:
```bash
make run-debug
```

---

## Command Usage Reference

The main entry point is `lkr`. 

### 1. Verification
```bash
# Debug credentials & check connectivity
uv run lkr load-test debug looker
```

### 2. Load Testing Dashboards
```bash
# Run a dashboard load test for 5 minutes with 25 users
uv run lkr load-test dashboard --dashboard <dashboard_id> --model <model_name> --users 25 --run-time 5
```

### 3. Load Testing Cookieless Embed Dashboards
```bash
uv run lkr load-test cookieless-embed-dashboard --dashboard <dashboard_id> --model <model_name> --users 25
```

### 4. Load Testing Queries (Explore QIDs)
```bash
uv run lkr load-test query --query <query_id> --model <model_name> --users 25
```

### 5. Load Testing Dashboard Rendering (PDF/PNG/JPG)
```bash
uv run lkr load-test render --dashboard <dashboard_id> --model <model_name> --result-format pdf
```

### 6. Embed Observability Load Testing
Starts a local web server to capture Looker javascript frontend metrics during simulated dashboard sessions:
```bash
uv run lkr load-test embed-observability --dashboard <dashboard_id> --port 4000
```

### 7. Deleting Embed Users (Cleanup)
SSO embed logins create new users in Looker. Clean them up using concurrent batch deletion:
```bash
# Dry run to see how many users match the prefix (defaults to first name "Embed")
uv run lkr load-test delete-embed-users --first-name "Embed" --dry-run

# Execute deletion with a limit
uv run lkr load-test delete-embed-users --first-name "Embed" --no-dry-run --limit 500
```

---

## Deployment

This tool is pre-packaged as a Docker image. You do not need to install Python or build any code to use it. You can run it effortlessly on a serverless Google Cloud Run Job by copying the command below:

1. Update `--project` to your Google Cloud project.
2. Provide your Looker API Credentials in the `--set-env-vars` flag.
3. Pass any script arguments into `--args`.

```bash
gcloud run jobs create delete-embed-users-job \
    --project=your-target-cloud-project \
    --region=us-central1 \
    --task-timeout=60 \
    --max-retries=0 \
    --execute-now \
    --image=us-west1-docker.pkg.dev/looker-scale-testing/delete-embed-users-v2/delete-embed-users:latest \
    --set-env-vars=LOOKERSDK_CLIENT_ID=YOUR_CLIENT_ID,LOOKERSDK_CLIENT_SECRET=YOUR_CLIENT_SECRET,LOOKERSDK_BASE_URL=https://yourinstance.cloud.looker.com \
    --command="lkr" \
    --args="delete-embed-users"
```

---

## Development

Use the included [Makefile](file:///Users/pankajgupta/Desktop/delete-embed-users/Makefile) for common development tasks:

- `make test` - Run pytest suites.
- `make format` - Format code and run pre-commit checks.
- `make clean` - Remove virtualenv, caches, and build artifacts.
