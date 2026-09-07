# Packaging

This directory builds **unmodified** [RiDDiX/adguard-tray](https://github.com/RiDDiX/adguard-tray)
releases into a `.deb`. CI uploads the package as a GitHub Release; the
combined APT repo at [jochemkuipers.github.io/apt-repo](https://jochemkuipers.github.io/apt-repo)
picks it up from there.

## Automatic updates

The Release workflow runs at 06:00 and 18:00 UTC. If RiDDiX has a newer
GitHub release, it bumps `debian/changelog`, builds, and uploads a Release.
A manual run with **force** rebuilds the currently packaged version.

## New upstream version (manual)

```bash
./packaging/sync-upstream.sh --update
# commit debian/changelog, tag vX.Y.Z, push
```

`uscan` also works (`debian/watch` points at RiDDiX GitHub tags).
