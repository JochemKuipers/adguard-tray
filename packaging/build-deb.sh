#!/usr/bin/env bash
# Fetch upstream and build adguard-tray_*_all.deb into ./dist
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -ge 1 ]]; then
  SRC="$("${ROOT}/packaging/fetch-upstream.sh" "$1")"
else
  SRC="$("${ROOT}/packaging/fetch-upstream.sh")"
fi

CHG="$(dpkg-parsechangelog -l "${ROOT}/debian/changelog" -S Version)"
UPSTREAM_VER="${CHG%-*}"
INIT="$(sed -n 's/^__version__ = "\(.*\)"/\1/p' "${SRC}/adguard_tray/__init__.py" | head -1)"

if [[ "${INIT}" != "${UPSTREAM_VER}" ]]; then
  echo "Upstream __version__ ${INIT} does not match debian/changelog ${CHG}" >&2
  exit 1
fi

(cd "${SRC}" && dpkg-buildpackage -us -uc -b)

mkdir -p "${ROOT}/dist"
cp -a "${ROOT}/upstream/adguard-tray_"*.deb "${ROOT}/dist/"
cp -a "${ROOT}/upstream/adguard-tray_"*.changes "${ROOT}/dist/" 2>/dev/null || true
cp -a "${ROOT}/upstream/adguard-tray_"*.buildinfo "${ROOT}/dist/" 2>/dev/null || true
ls -l "${ROOT}/dist"
