# DeepSeek Harness Docker deployment

This directory runs the official DeepSeek Harness Web UI in Docker. The
container stores Harness settings, credentials, profiles, and sessions in the
named `dsh-home` volume. A persistent `dsh-workspace` volume is mounted at
`/workspace`.

## Portainer deployment

Deploy this directory or its Git repository as a stack on a Linux Docker
server. The build context must contain `compose.yaml`, `Dockerfile`, and
`web.cordis.yml`. The Caddy configuration is embedded in `compose.yaml`, and
the workspace is a named volume, so no additional files or host directories
are required.

Both services use host networking. Harness discovers the Docker server's LAN
interfaces through its built-in all-interface runtime, and Caddy derives the
certificate address from the destination of each TLS connection. No LAN IP
address or hostname is configured in the stack.

## First run

In PowerShell:

```powershell
Copy-Item .env.example .env
docker compose up -d
docker compose logs -f caddy
```

If `DEEPSEEK_API_KEY` is set in `.env`, the container inherits it
automatically. It can also be entered later in the Web UI.

## LAN access

The stack terminates HTTPS with Caddy and proxies to Harness over host
loopback. The Caddy configuration is embedded in `compose.yaml`, and the
Harness workspace uses a Docker-managed volume. No companion Caddyfile or host
workspace-directory setup is required. Use:

```text
https://DOCKER-SERVER-IP/
```

Standard HTTP redirects automatically:

```text
http://DOCKER-SERVER-IP/
```

Ports 80, 443, and 3080 must be available on the Docker server. Port 3080 is
the Harness listener used by the local Caddy reverse proxy.

The service uses `pull_policy: build`, so Compose rebuilds the local image each
time the stack is started or refreshed.

## Model server and API key selection

Open **Settings → Models** in the LAN browser. Caddy presents its internal
Harness connection as loopback-same-origin so the existing Harness settings,
credential, and model-discovery operations are available through the HTTPS
entrypoint. The LAN firewall remains the deployment access boundary.

To point the native DeepSeek provider at another endpoint:

1. Open the DeepSeek provider card.
2. Enter the API key.
3. Expand **Custom settings**, set the base URL, and edit the model list.
4. Apply the changes, then select the model in the conversation model picker.

For vLLM, Ollama, LM Studio, or another OpenAI-compatible server, choose
**Add a custom provider** and enter:

- A permanent lowercase provider ID.
- The server's OpenAI-compatible base URL, normally ending in `/v1`.
- The `openai-completions` API protocol.
- The API key and at least one model, or use **Fetch available models**.

Use `http://localhost:PORT/v1` when the model server listens on the same Linux
Docker host. A model server running in another container must publish its API
port on that host. For a model server elsewhere on the LAN, enter that
server's reachable hostname or address instead.

The OpenAI-compatible adapter expects a non-empty key even when the local
server ignores authentication; a placeholder value is sufficient in that
case. Provider settings and UI-entered credentials persist in the `dsh-home`
volume. An inherited `DEEPSEEK_API_KEY` has operator precedence and is
read-only in the UI, so leave that environment value empty when the Models
page should own the official DeepSeek credential.

### Local certificate

Caddy uses its internal certificate authority because private LAN addresses
cannot use a publicly trusted certificate. Install its root certificate once
on each browser client. On a Windows client, run PowerShell:

```powershell
$server = Read-Host 'Docker server IP address'
Invoke-WebRequest -Uri "http://$server/caddy-local-root.crt" -OutFile .\caddy-local-root.crt
Import-Certificate -FilePath .\caddy-local-root.crt -CertStoreLocation Cert:\CurrentUser\Root
```

Restart the browser after importing the certificate. Firefox installations
that use their own certificate store require importing the same file through
Firefox settings. Caddy's certificate storage is persisted in the
`caddy-data` volume.

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
