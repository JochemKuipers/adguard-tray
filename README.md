# adguard-tray APT repository

Unofficial Debian packages of [RiDDiX/adguard-tray](https://github.com/RiDDiX/adguard-tray).
This repo does **not** carry a fork of the app — CI downloads the upstream
release tarball, wraps it in `debian/`, and publishes a signed APT repo.

## Install

```bash
curl -fsSL https://jochemkuipers.github.io/adguard-tray/install.sh | sudo bash
```

Then `adguard-tray`. Updates come in with the rest of the system:

```bash
sudo apt update && sudo apt upgrade
```

`adguard-cli` is still installed with [AdGuard's official script](https://github.com/AdguardTeam/AdGuardCLI).

The app's own "Application update" button talks to GitHub; on an apt install
use `apt upgrade` instead.

## Package a new upstream release

```bash
./packaging/sync-upstream.sh          # compare to the latest GitHub release
./packaging/sync-upstream.sh --update # bump debian/changelog
git add debian/changelog
git commit -m "chore: package upstream X.Y.Z"
git tag vX.Y.Z
git push origin HEAD vX.Y.Z
```

CI fetches `https://github.com/RiDDiX/adguard-tray/archive/refs/tags/vX.Y.Z.tar.gz`,
builds the `.deb`, and publishes
`https://jochemkuipers.github.io/adguard-tray`.

Local build (no publish):

```bash
sudo apt install debhelper dh-python dpkg-dev devscripts curl
./packaging/build-deb.sh          # version from debian/changelog
sudo apt install ./dist/adguard-tray_*_all.deb
```

## One-time publishing setup

See [packaging/README.md](packaging/README.md) for the APT signing key and
GitHub Pages secrets.

## Layout

| Path | Role |
|---|---|
| `debian/` | Packaging only (not shipped by upstream) |
| `packaging/` | Fetch, build, and publish helpers |
| `install.sh` | Adds this APT source on a Debian machine |
