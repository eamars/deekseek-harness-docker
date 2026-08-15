# DeepSeek Harness Docker deployment

This directory runs the official DeepSeek Harness Web UI in Docker. The
container stores Harness settings, credentials, profiles, and sessions in the
named `dsh-home` volume. The host workspace is mounted at `/workspace`.

## First run

In PowerShell:

```powershell
Copy-Item .env.example .env
New-Item -ItemType Directory -Path .\workspace -Force
docker compose up --build -d
docker compose logs -f deepseek-harness
```

Open <http://127.0.0.1:3080>, choose `/workspace`, and configure the model in
**Settings → Models**. If `DEEPSEEK_API_KEY` is set in `.env`, the container
inherits it automatically.

## Stop and upgrade

```powershell
docker compose down
docker compose up --build -d
```

The named volume is preserved by `docker compose down`. Do not add `-v` unless
you intend to remove the persisted Harness settings, credentials, and sessions.

## Remote reverse-proxy deployment

Keep the Harness container behind an authenticated TLS reverse proxy. Change
the port mapping to `3080:3080` and set the public authority in `.env`:

```dotenv
DSH_TRUSTED_HOST=harness.example.com
```

The raw Harness Web UI has no TLS or authentication layer and should not be
published directly to the Internet.

## Upstream references

- <https://github.com/deepseek-ai/deepseek-harness>
- <https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/index.md>
- <https://github.com/deepseek-ai/deepseek-harness/blob/master/apps/cli/reference/README.md>
