#!/usr/bin/env bash
# Publishes dist/ as a GitHub Release. Build dist/ first with the app repo's
# tool/hadith_books/build_release.py (the --base-url must match this tag).
#
#   scripts/publish.sh 2026.09.1
set -euo pipefail

VERSION="${1:?usage: scripts/publish.sh <corpus-version>}"
REPO="bilalelsayed97/hadith-nine-books-data"
TAG="v${VERSION}"
cd "$(dirname "$0")/.."

grep -q "\"corpusVersion\": \"${VERSION}\"" dist/manifest.json \
  || { echo "dist/manifest.json is not version ${VERSION}" >&2; exit 1; }
grep -q "releases/download/${TAG}/" dist/manifest.json \
  || { echo "manifest URLs do not point at ${TAG}" >&2; exit 1; }

# Verify every asset against the manifest before uploading.
python3 - <<'PY'
import hashlib, json, pathlib
manifest = json.loads(pathlib.Path("dist/manifest.json").read_text())
for book in manifest["books"]:
    path = pathlib.Path("dist") / book["url"].rsplit("/", 1)[1]
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    assert path.stat().st_size == book["gzSize"], f"{path}: size mismatch"
    assert digest == book["gzSha256"], f"{path}: sha256 mismatch"
print(f"verified {len(manifest['books'])} assets")
PY

cp dist/manifest.json manifest.json
git add manifest.json
git commit -m "Release ${TAG}" || true
git push

gh release create "${TAG}" dist/*.db.gz dist/manifest.json \
  --repo "${REPO}" \
  --title "Nine Books corpus ${VERSION}" \
  --notes "Per-book SQLite databases (gzip) and manifest.json for corpus ${VERSION}."
