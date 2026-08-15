# DeepSeek Harness Docker deployment

This directory runs the official DeepSeek Harness Web UI in Docker. The
container stores Harness settings, credentials, profiles, and sessions in the
named `dsh-home` volume. The host workspace is mounted at `/workspace`.

## First run

In PowerShell:

```powershell
Copy-Item .env.example .env
New-Item -ItemType Directory -Path .\workspace -Force
docker compose up -d
docker compose logs -f caddy
```

The default LAN address is `192.168.2.10`. If the Docker host uses another
address, edit `LAN_HOST` in `.env` before starting the stack. If
`DEEPSEEK_API_KEY` is set in `.env`, the container inherits it automatically.

## LAN access

The stack terminates HTTPS with Caddy and proxies to Harness over the internal
Compose network. Use:

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
private LAN address. On the first run, browsers may show a certificate warning.
To trust the certificate on a Windows client, copy the Caddy root certificate:

```powershell
docker compose cp caddy:/data/caddy/pki/authorities/local/root.crt .\caddy-local-root.crt
Import-Certificate -FilePath .\caddy-local-root.crt -CertStoreLocation Cert:\CurrentUser\Root
```

Install that root certificate on each LAN client that will use the UI. Caddy's
certificate storage is persisted in the `caddy-data` volume.

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
sessions, and local certificate authority.

## Upstream references

- <https://github.com/deepseek-ai/deepseek-harness>
- <https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/index.md>
- <https://github.com/deepseek-ai/deepseek-harness/blob/master/apps/cli/reference/README.md>
- <https://caddyserver.com/docs/caddyfile/directives/tls>
