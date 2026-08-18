#!/usr/bin/env bash
set -Eeuo pipefail

profile_dir="${DSH_HOME}/profiles/web"
market_manifest="${profile_dir}/node_modules/dshmarket/package.json"
installed_market_version=""

if [[ -f "${market_manifest}" ]]; then
  installed_market_version="$(
    node -e '
      const fs = require("node:fs");
      try {
        const packageJson = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
        process.stdout.write(packageJson.version ?? "");
      } catch {
        process.exitCode = 1;
      }
    ' "${market_manifest}" 2>/dev/null || true
  )"
fi

if [[ "${installed_market_version}" != "${DSH_MARKET_VERSION}" ]]; then
  echo "Installing dsh-market ${DSH_MARKET_VERSION} into the web profile..."
  dsh plugin --profile web add --save-exact "dshmarket@${DSH_MARKET_VERSION}"
fi

if [[ ! -f "${market_manifest}" ]]; then
  echo "dsh-market was not installed into ${profile_dir}" >&2
  exit 1
fi

exec dsh web --patch /opt/dsh/web.cordis.yml "$@"
