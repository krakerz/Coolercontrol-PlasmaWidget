#!/usr/bin/env bash
# Builds a .plasmoid archive (metadata.json + contents/ at the zip root) —
# the standard installable/distributable format for a Plasma widget.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

VERSION="$(python3 -c "import json; print(json.load(open('metadata.json'))['KPlugin']['Version'])")"
OUT="coolercontrol-monitor-${VERSION}.plasmoid"

rm -f "$OUT"

python3 - "$OUT" <<'EOF'
import os
import sys
import zipfile

out = sys.argv[1]
files = ["metadata.json"]
for root, _dirs, names in os.walk("contents"):
    for name in names:
        if name.endswith((".qmlc", ".jsc")):
            continue
        files.append(os.path.join(root, name))

with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
    for f in sorted(files):
        zf.write(f, f)
EOF

echo "Built $OUT"
