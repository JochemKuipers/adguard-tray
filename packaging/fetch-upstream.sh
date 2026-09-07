#!/usr/bin/env bash
# Download an unmodified RiDDiX/adguard-tray release and overlay debian/.
# Prints the extracted source path on stdout; progress goes to stderr.
set -euo pipefail

UPSTREAM_REPO="RiDDiX/adguard-tray"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -ge 1 ]]; then
  VERSION="$1"
else
  VERSION="$(dpkg-parsechangelog -l "${ROOT}/debian/changelog" -S Version)"
  VERSION="${VERSION%-*}"
fi

DEST="${ROOT}/upstream"
ARCHIVE="${DEST}/adguard-tray_${VERSION}.orig.tar.gz"
SRC="${DEST}/adguard-tray-${VERSION}"
URL="https://github.com/${UPSTREAM_REPO}/archive/refs/tags/v${VERSION}.tar.gz"

mkdir -p "${DEST}"
echo "Fetching ${URL}" >&2
curl -fsSL -o "${ARCHIVE}" "${URL}"

rm -rf "${SRC}" "${DEST}/adguard-tray-v${VERSION}"
tar -xzf "${ARCHIVE}" -C "${DEST}"

if [[ ! -d "${SRC}" && -d "${DEST}/adguard-tray-v${VERSION}" ]]; then
  mv "${DEST}/adguard-tray-v${VERSION}" "${SRC}"
fi
if [[ ! -d "${SRC}" ]]; then
  echo "Unexpected archive layout in ${DEST}:" >&2
  ls -la "${DEST}" >&2
  exit 1
fi

rm -rf "${SRC}/debian"
cp -a "${ROOT}/debian" "${SRC}/debian"

echo "${SRC}"
