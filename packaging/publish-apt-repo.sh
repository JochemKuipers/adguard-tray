#!/usr/bin/env bash
# Rebuild a static APT repository in REPO_ROOT, adding the given .deb files.
# Signs Release / InRelease with the first secret key in the current GnuPG
# keyring (import the CI key before calling this).
set -euo pipefail

usage() {
  echo "usage: $0 REPO_ROOT deb [deb...]" >&2
  exit 2
}

[[ $# -ge 2 ]] || usage

REPO_ROOT="$1"
shift

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POOL="pool/main/a/adguard-tray"
GPG_ARGS=(--batch --yes --pinentry-mode loopback)
if [[ -n "${GPG_PASSPHRASE:-}" ]]; then
  GPG_ARGS+=(--passphrase-fd 0)
fi

mkdir -p "${REPO_ROOT}/${POOL}"
for deb in "$@"; do
  [[ -f "$deb" ]] || { echo "not a file: $deb" >&2; exit 1; }
  cp -a "$deb" "${REPO_ROOT}/${POOL}/"
done

if [[ -f "${SCRIPT_DIR}/index.html" ]]; then
  cp -a "${SCRIPT_DIR}/index.html" "${REPO_ROOT}/index.html"
fi
if [[ -f "${SCRIPT_DIR}/../install.sh" ]]; then
  cp -a "${SCRIPT_DIR}/../install.sh" "${REPO_ROOT}/install.sh"
fi
touch "${REPO_ROOT}/.nojekyll"

for arch in all amd64 arm64; do
  dest="${REPO_ROOT}/dists/stable/main/binary-${arch}"
  mkdir -p "$dest"
  (cd "$REPO_ROOT" && apt-ftparchive packages "$POOL") > "${dest}/Packages"
  gzip -9n -c "${dest}/Packages" > "${dest}/Packages.gz"
done

mkdir -p "${REPO_ROOT}/dists/stable"
cat > "${REPO_ROOT}/dists/stable/apt-release.conf" <<'EOF'
APT::FTPArchive::Release::Origin "adguard-tray";
APT::FTPArchive::Release::Label "adguard-tray";
APT::FTPArchive::Release::Suite "stable";
APT::FTPArchive::Release::Codename "stable";
APT::FTPArchive::Release::Architectures "all amd64 arm64";
APT::FTPArchive::Release::Components "main";
APT::FTPArchive::Release::Description "adguard-tray APT repository";
EOF

(cd "${REPO_ROOT}/dists/stable" && apt-ftparchive -c apt-release.conf release .) \
  > "${REPO_ROOT}/dists/stable/Release"

sign() {
  local extra=()
  if [[ -n "${GPG_KEY_ID:-}" ]]; then
    extra+=(-u "$GPG_KEY_ID")
  fi
  if [[ -n "${GPG_PASSPHRASE:-}" ]]; then
    printf '%s' "$GPG_PASSPHRASE" | gpg "${GPG_ARGS[@]}" "${extra[@]}" "$@"
  else
    gpg --batch --yes "${extra[@]}" "$@"
  fi
}

rm -f "${REPO_ROOT}/dists/stable/InRelease" "${REPO_ROOT}/dists/stable/Release.gpg"
sign --clearsign -o "${REPO_ROOT}/dists/stable/InRelease" \
  "${REPO_ROOT}/dists/stable/Release"
sign -abs -o "${REPO_ROOT}/dists/stable/Release.gpg" \
  "${REPO_ROOT}/dists/stable/Release"

if [[ -n "${GPG_KEY_ID:-}" ]]; then
  gpg --batch --export --armor "$GPG_KEY_ID" > "${REPO_ROOT}/adguard-tray.asc"
else
  gpg --batch --export --armor > "${REPO_ROOT}/adguard-tray.asc"
fi

echo "APT repository written to ${REPO_ROOT}"
