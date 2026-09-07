#!/usr/bin/env bash
# Compare debian/changelog to the latest RiDDiX GitHub release.
#   --update  write a new changelog entry when upstream is newer
#   --ci      same, and always exit 0 (writes GitHub Actions outputs)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPDATE=0
CI=0
for arg in "$@"; do
  case "$arg" in
    --update) UPDATE=1 ;;
    --ci)     CI=1; UPDATE=1 ;;
    *)
      echo "usage: $0 [--update|--ci]" >&2
      exit 2
      ;;
  esac
done

write_output() {
  local key="$1" value="$2"
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    printf '%s=%s\n' "$key" "$value" >> "${GITHUB_OUTPUT}"
  fi
}

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

newer=0
if [[ "${LATEST}" != "${CURRENT}" ]]; then
  highest="$(printf '%s\n%s\n' "${CURRENT}" "${LATEST}" | sort -V | tail -1)"
  if [[ "${highest}" == "${LATEST}" ]]; then
    newer=1
  else
    echo "Packaged version is newer than upstream latest; leaving changelog alone."
  fi
fi

if [[ "${newer}" -eq 0 ]]; then
  echo "Already packaging the latest upstream release."
  write_output current "${CURRENT}"
  write_output latest "${LATEST}"
  write_output version "${CURRENT}"
  write_output deb_version "$(dpkg-parsechangelog -l "${ROOT}/debian/changelog" -S Version)"
  write_output build false
  write_output updated false
  exit 0
fi

if [[ "${UPDATE}" -ne 1 ]]; then
  echo "Newer upstream is available. Run:"
  echo "  ./packaging/sync-upstream.sh --update"
  echo "  git add debian/changelog && git commit && git tag v${LATEST} && git push origin HEAD v${LATEST}"
  write_output current "${CURRENT}"
  write_output latest "${LATEST}"
  write_output version "${LATEST}"
  write_output build true
  write_output updated false
  exit 2
fi

export DEBFULLNAME="${DEBFULLNAME:-Jochem Kuipers}"
export DEBEMAIL="${DEBEMAIL:-jochem@kuipers.cc}"
dch --changelog "${ROOT}/debian/changelog" --newversion "${LATEST}-1" --distribution unstable \
  "Package upstream ${LATEST}."
echo "Updated debian/changelog to ${LATEST}-1"

write_output current "${CURRENT}"
write_output latest "${LATEST}"
write_output version "${LATEST}"
write_output deb_version "${LATEST}-1"
write_output build true
write_output updated true

if [[ "${CI}" -eq 1 ]]; then
  exit 0
fi
echo "Commit, tag v${LATEST}, and push to publish."
