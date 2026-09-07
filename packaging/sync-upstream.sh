#!/usr/bin/env bash
# Compare debian/changelog to the latest RiDDiX GitHub release.
# With --update, write a new changelog entry when upstream is newer.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPDATE=0
if [[ "${1:-}" == "--update" ]]; then
  UPDATE=1
fi

CURRENT="$(dpkg-parsechangelog -l "${ROOT}/debian/changelog" -S Version)"
CURRENT="${CURRENT%-*}"

API="https://api.github.com/repos/RiDDiX/adguard-tray/releases/latest"
TAG="$(curl -fsSL -H 'Accept: application/vnd.github+json' "${API}" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tag_name",""))')"
LATEST="${TAG#v}"

if [[ -z "${LATEST}" ]]; then
  echo "Could not read the latest upstream tag" >&2
  exit 1
fi

echo "Packaged:  ${CURRENT}"
echo "Upstream:  ${LATEST}  (${TAG})"

if [[ "${LATEST}" == "${CURRENT}" ]]; then
  echo "Already packaging the latest upstream release."
  exit 0
fi

if [[ "${UPDATE}" -ne 1 ]]; then
  echo "Newer upstream is available. Run:"
  echo "  ./packaging/sync-upstream.sh --update"
  echo "  git add debian/changelog && git commit && git tag v${LATEST} && git push origin HEAD v${LATEST}"
  exit 2
fi

export DEBFULLNAME="${DEBFULLNAME:-Jochem Kuipers}"
export DEBEMAIL="${DEBEMAIL:-jochem@kuipers.cc}"
dch --changelog "${ROOT}/debian/changelog" --newversion "${LATEST}-1" --distribution stable \
  "Package upstream ${LATEST}."
echo "Updated debian/changelog to ${LATEST}-1"
echo "Commit, tag v${LATEST}, and push to publish."
