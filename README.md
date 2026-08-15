# DeepSeek Harness Docker deployment

This directory runs the official DeepSeek Harness Web UI in Docker. The
container stores Harness settings, credentials, profiles, and sessions in the
named `dsh-home` volume. A persistent `dsh-workspace` volume is mounted at
`/workspace`.

## Portainer deployment

Deploy this directory or its Git repository as a stack. The build context must
contain `compose.yaml`, `Dockerfile`, and `web.cordis.yml`. The Caddy
configuration is embedded in `compose.yaml`, and the workspace is a named
volume, so no additional files or host directories are required. The defaults
already target `192.168.2.10` on HTTPS port 443.

## First run

In PowerShell:

```powershell
Copy-Item .env.example .env
docker compose up -d
docker compose logs -f caddy
```

The default LAN address is `192.168.2.10`. If the Docker host uses another
address, edit `LAN_HOST` in `.env` before starting the stack. If
`DEEPSEEK_API_KEY` is set in `.env`, the container inherits it automatically.

## LAN access

The stack terminates HTTPS with Caddy and proxies to Harness over the internal
Compose network. The Caddy configuration is embedded in `compose.yaml`, and
the Harness workspace uses a Docker-managed volume. No companion Caddyfile or
host workspace-directory setup is required. Use:

```text
https://192.168.2.10/
```

The old HTTP URL redirects automatically:

```text
http://192.168.2.10:3080/
```

The service uses `pull_policy: build`, so Compose rebuilds the local image each
time the stack is started or refreshed.

### Local certificate

Caddy uses its internal certificate authority because `192.168.2.10` is a
private LAN address. Install its root certificate once on each browser client.
On a Windows client, run PowerShell:

```powershell
Invoke-WebRequest -Uri 'http://192.168.2.10:3080/caddy-local-root.crt' -OutFile .\caddy-local-root.crt
Import-Certificate -FilePath .\caddy-local-root.crt -CertStoreLocation Cert:\CurrentUser\Root
```

Restart the browser after importing the certificate. Firefox installations
that use their own certificate store require importing the same file through
Firefox settings. Caddy's certificate storage is persisted in the
`caddy-data` volume.

If port 443 is already in use, set `HTTPS_PORT=8443` in `.env` and use
`https://192.168.2.10:8443/` instead.

For a clean rebuild with detailed build output:

```powershell
docker compose build --no-cache --progress=plain
docker compose up -d
```

## Stop and upgrade

```powershell
docker compose down
docker compose up --build -d
```

The named volumes are preserved by `docker compose down`. Do not add `-v`
unless you intend to remove the persisted Harness settings, credentials,
sessions, workspace, and local certificate authority.

## Upstream references

- <https://github.com/deepseek-ai/deepseek-harness>
- <https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/index.md>
- <https://github.com/deepseek-ai/deepseek-harness/blob/master/apps/cli/reference/README.md>
- <https://caddyserver.com/docs/caddyfile/directives/tls>
