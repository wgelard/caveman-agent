---
applyTo: "**/Dockerfile*,**/*.dockerfile,**/docker-compose*.{yml,yaml},.dockerignore"
description: "Docker best practices: multi-stage builds, minimal images, non-root user, security hygiene, Compose. Use when working on Docker files."
---

## Docker Best Practices

### Dockerfile

- Use official minimal base images: `alpine`, `distroless`, or `-slim` variants. Pin exact digest or version tag — never `latest`.
- Multi-stage builds: separate builder and runtime stages to minimize final image size.
- `COPY --chown=<user>:<group>` instead of `RUN chown` — avoids extra layer.
- Run as non-root: create a dedicated user and `USER` it before `CMD`/`ENTRYPOINT`.
- Order layers by change frequency: system deps first, app deps second, source last. Maximizes cache hits.
- One `RUN` per logical group (system packages, app install, cleanup) — combine with `&&` and clean package cache in the same layer.
- Never store secrets in any layer. Use build args only for non-secret config; secrets at runtime via env vars or mounts.
- Use `COPY` over `ADD` unless you explicitly need URL fetching or auto-extract.
- Always define `HEALTHCHECK`.
- Pin base image digest for reproducibility in production:
  ```dockerfile
  FROM node:22-alpine@sha256:<digest>
  ```

### .dockerignore

- Always include: `.git`, `node_modules`, `__pycache__`, `.venv`, `build/`, `dist/`, `*.log`, `.env*`.
- Mirror `.gitignore` as a baseline; prune further for build context size.

### Security

- No secrets in `ENV` or `ARG` in final stage.
- Minimize installed packages — no build tools in runtime image.
- Use `--no-install-recommends` for apt, `--no-cache` for apk.
- Scan images: `docker scout cves <image>` or `trivy image <image>`.
- Drop capabilities in `docker run`/Compose: `cap_drop: [ALL]`, add back only what's needed.

### Docker Compose

- Use named volumes, not bind mounts, for data that must persist.
- Define `depends_on` with `condition: service_healthy` when order matters.
- Use `.env` files for environment config; never commit `.env`.
- Set `restart: unless-stopped` for services that must survive host reboots.
- Pin image tags in `docker-compose.yml`; never use `latest` in production.
- Use `profiles` to separate dev/test services from core services.

### Multi-stage example pattern

```dockerfile
# --- Build stage ---
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /bin/app ./cmd/app

# --- Runtime stage ---
FROM gcr.io/distroless/static-debian12
COPY --from=builder /bin/app /app
USER nonroot:nonroot
ENTRYPOINT ["/app"]
```
