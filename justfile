_default:
  just --list

format: _format-json _format-xml _format-css

validate: _validate-json _validate-xml _validate-css _validate-toml

_format-json:
  #!/usr/bin/env bash
  set -euo pipefail
  git ls-files -z '*.json' | while IFS= read -r -d '' f; do
    jq . "$f" > "$f.tmp"
    mv "$f.tmp" "$f"
  done

_format-xml:
  #!/usr/bin/env bash
  set -euo pipefail
  git ls-files -z '*.xml' '*.tmTheme' | while IFS= read -r -d '' f; do
    xmllint --format "$f" --output "$f.tmp"
    mv "$f.tmp" "$f"
  done

_format-css:
  #!/usr/bin/env bash
  set -euo pipefail
  git ls-files -z '*.css' | xargs -0 -r npx --yes prettier --write

_validate-json:
  #!/usr/bin/env bash
  set -euo pipefail
  git ls-files -z '*.json' | while IFS= read -r -d '' f; do
    jq empty "$f" || { echo "invalid JSON: $f" >&2; exit 1; }
  done

_validate-xml:
  #!/usr/bin/env bash
  set -euo pipefail
  git ls-files -z '*.xml' '*.tmTheme' | while IFS= read -r -d '' f; do
    xmllint --noout "$f" || { echo "invalid XML: $f" >&2; exit 1; }
  done

_validate-css:
  #!/usr/bin/env bash
  set -euo pipefail
  git ls-files -z '*.css' | xargs -0 -r npx --yes prettier --check

_validate-toml:
  #!/usr/bin/env bash
  set -euo pipefail
  git ls-files -z '*.toml' | while IFS= read -r -d '' f; do
    python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$f" || { echo "invalid TOML: $f" >&2; exit 1; }
  done
