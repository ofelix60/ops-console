#!/usr/bin/env bash
set -euo pipefail

# Pull the SQL and JavaScript out of the exported n8n workflows into readable files.
# Reads workflows/*.json (already scrubbed by export-workflows.sh), so it needs no
# secrets and can run on its own. queries/n8n/ is regenerated from scratch each run,
# so the readable copies can never drift from the workflows.

out_dir=queries/n8n
rm -rf "$out_dir"
mkdir -p "$out_dir"

for f in workflows/*.json; do
  workflow=$(jq -r '.name' "$f")

  # One compact JSON line per node that holds a query or code
  jq -c '.nodes[]
         | select(.parameters.query or .parameters.jsCode)
         | {name, code: (.parameters.query // .parameters.jsCode),
            ext: (if .parameters.query then "sql" else "js" end)}' "$f" |
  while IFS= read -r node; do
    name=$(jq -r '.name' <<<"$node")
    ext=$(jq -r '.ext' <<<"$node")
    slug=$(tr '[:upper:] ' '[:lower:]-' <<<"$name")
    [ "$ext" = sql ] && comment='--' || comment='//'

    {
      echo "$comment Generated from $f (workflow \"$workflow\", node \"$name\")"
      echo "$comment by scripts/extract-queries.sh. Do not edit; change the workflow and re-export."
      echo
      # n8n stores expression-mode fields with a leading "="
      jq -r '.code | sub("^="; "")' <<<"$node"
    } > "$out_dir/$workflow.$slug.$ext"
  done
done

echo "✻ Extracted queries and code into $out_dir/"
