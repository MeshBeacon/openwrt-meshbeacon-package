# Building clusterduckd / luci-app-clusterduckd locally

This repo only contains the OpenWrt package sources (Makefiles, init script,
UCI config, LuCI files). You need an OpenWrt SDK to actually compile the
`.ipk` files — the SDK is not part of this repo.

## 1. Get the SDK

Download and extract the SDK for `ramips/mt76x8` matching OpenWrt 21.02.3:

```bash
curl -fLO https://downloads.openwrt.org/releases/21.02.3/targets/ramips/mt76x8/openwrt-sdk-21.02.3-ramips-mt76x8_gcc-8.4.0_musl.Linux-x86_64.tar.xz
tar xJf openwrt-sdk-21.02.3-ramips-mt76x8_gcc-8.4.0_musl.Linux-x86_64.tar.xz
cd openwrt-sdk-21.02.3-ramips-mt76x8_gcc-8.4.0_musl.Linux-x86_64
```

If you already have this SDK checked out elsewhere (e.g.
`~/Projects/openwrt-sdk-21.02.3-ramips-mt76x8_gcc-8.4.0_musl.Linux-x86_64`),
you can reuse it directly and skip the download.

### Architecture support

`package/network/services/clusterduckd/Makefile` picks the upstream prebuilt
binary automatically based on the SDK's target architecture (`$(ARCH)`,
derived from the SDK's own `CONFIG_ARCH`):

| SDK target arch | Binary fetched |
| --- | --- |
| `mipsel` (e.g. ramips/mt76x8) | `clusterduckd-vX.Y.Z-linux-mipsel-24kec` |
| `mips` (e.g. ath79/generic -- AR9331 boards) | `clusterduckd-vX.Y.Z-linux-mips-24kc` |
| `aarch64` (any arm64 target) | `clusterduckd-vX.Y.Z-linux-arm64` |

No Makefile edits are needed to switch targets -- just drop the package
directories into whichever SDK you're building against, matching step 2
below.

### CI builds

[.github/workflows/build.yml](.github/workflows/build.yml) builds all three
architectures on every push to `main` / manual run: `ramips/mt76x8`
(mipsel-24kec), `ath79/generic` (mips-24kc, e.g. AR9331 boards), and
`bcm27xx/bcm2711` (arm64, e.g. Raspberry Pi 4). All `.ipk` files are
uploaded as workflow artifacts and, outside of pull requests, published as
assets on a GitHub Release tagged with the clusterduckd version being built
(e.g. `v1.2.3` — either the version pinned in the Makefile, or the
`clusterduckd_version` input/"latest" when manually dispatched). Re-running
the workflow for an already-released version reuses that release and
replaces its `.ipk` assets.

## 2. Drop the packages into the SDK

From the SDK root:

```bash
SDK=$(pwd)
FEED=/path/to/clusterduckd-openwrt-feed   # this repo

rm -rf "$SDK/package/network/services/clusterduckd" \
       "$SDK/package/network/services/luci-app-clusterduckd"
cp -r "$FEED/package/network/services/clusterduckd" \
      "$FEED/package/network/services/luci-app-clusterduckd" \
      "$SDK/package/network/services/"
```

## 3. Configure and build

A one-time `defconfig` is needed on a fresh SDK checkout:

```bash
make defconfig
```

Then build each package:

```bash
make package/network/services/clusterduckd/{clean,compile} V=s
make package/network/services/luci-app-clusterduckd/{clean,compile} V=s
```

> **Note:** You'll see warnings like `Makefile ... has a dependency on
> 'jshn', which does not exist` and `... 'luci-base', which does not exist`.
> These are harmless for direct package builds — `jshn` and `luci-base` are
> only unresolved because this SDK has no feeds installed. They only matter
> if you run `make menuconfig` / build a full firmware image, in which case
> install feeds first:
>
> ```bash
> cp feeds.conf.default feeds.conf
> ./scripts/feeds update -a
> ./scripts/feeds install jshn libubox luci-base
> ```

The first build of any package in a fresh SDK checkout may also rebuild the
base toolchain (libc, libgcc, libstdc++, etc.) — this is normal and only
happens once (or whenever staging directories are invalidated).

## 4. Find the built packages

```bash
ls bin/packages/mipsel_24kc/base/clusterduckd*.ipk
ls bin/packages/mipsel_24kc/base/luci-app-clusterduckd*.ipk
```

(Substitute `mipsel_24kc` with the matching `bin/packages/<arch>/base/`
directory if you built against an ath79/generic (mips-24kc) or arm64 SDK
instead.)

## Service is disabled by default

The daemon ships with `option enabled '0'` in `/etc/config/clusterduckd` and
`start_service()` returns immediately unless it's set to `1`. After
installing the `.ipk`, enable it either via LuCI (tick **Enable** under
*ClusterDuck Gateway → General* and save) or manually:

```sh
uci set clusterduckd.settings.enabled='1'
uci commit clusterduckd
/etc/init.d/clusterduckd enable
/etc/init.d/clusterduckd start
```

## 5. (Optional) Inspect an .ipk without installing it

`.ipk` files are `ar` archives containing `control.tar.gz` and
`data.tar.gz`:

```bash
mkdir -p /tmp/ipk_check && cd /tmp/ipk_check
tar xf /path/to/clusterduckd_1.2.2-1_mipsel_24kc.ipk
tar tzf data.tar.gz
tar xzf data.tar.gz
cat etc/config/clusterduckd
cat etc/init.d/clusterduckd
```

## Building a specific clusterduckd release version

By default the Makefile pins a specific `PKG_VERSION`/`PKG_HASH`. To build a
different release without editing the committed Makefile, override both
before compiling (the hash must match the real asset or the download step
will fail verification):

```bash
VERSION=1.2.3
TAG="v$VERSION"
ARCH_SUFFIX=linux-mipsel-24kec   # or linux-mips-24kc (ath79/AR9331), linux-arm64 (aarch64)
ASSET="clusterduckd-${TAG}-${ARCH_SUFFIX}"
HASH=$(curl -fsSL "https://github.com/MeshBeacon/meshbeacon-uplink/releases/download/${TAG}/${ASSET}" | sha256sum | cut -d' ' -f1)

MAKEFILE=package/network/services/clusterduckd/Makefile
sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=${VERSION}/" "$MAKEFILE"
# Only patch the branch matching $ARCH_SUFFIX (ifeq/aarch64, else ifeq/mips,
# or the final else/mipsel), leaving the other two untouched:
case "$ARCH_SUFFIX" in
  linux-arm64)
    sed -i "/^ifeq (\$(ARCH),aarch64)/,/^else ifeq (\$(ARCH),mips)/{s/^\(\s*PKG_SOURCE:=\).*/\1${ASSET}/; s/^\(\s*PKG_HASH:=\).*/\1${HASH}/}" "$MAKEFILE"
    ;;
  linux-mips-24kc)
    sed -i "/^else ifeq (\$(ARCH),mips)/,/^else$/{s/^\(\s*PKG_SOURCE:=\).*/\1${ASSET}/; s/^\(\s*PKG_HASH:=\).*/\1${HASH}/}" "$MAKEFILE"
    ;;
  *)
    sed -i "/^else$/,/^endif/{s/^\(\s*PKG_SOURCE:=\).*/\1${ASSET}/; s/^\(\s*PKG_HASH:=\).*/\1${HASH}/}" "$MAKEFILE"
    ;;
esac
```

This is exactly what [.github/workflows/build.yml](.github/workflows/build.yml) automates in CI via the
`clusterduckd_version` workflow input, once per matrix leg.
