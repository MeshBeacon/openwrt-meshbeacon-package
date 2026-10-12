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
ASSET="clusterduckd-${TAG}-linux-mipsel-24kec"
HASH=$(curl -fsSL "https://github.com/MeshBeacon/meshbeacon-uplink/releases/download/${TAG}/${ASSET}" | sha256sum | cut -d' ' -f1)

sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=${VERSION}/" package/network/services/clusterduckd/Makefile
sed -i "s/^PKG_HASH:=.*/PKG_HASH:=${HASH}/" package/network/services/clusterduckd/Makefile
```

This is exactly what [.github/workflows/build.yml](.github/workflows/build.yml) automates in CI via the
`clusterduckd_version` workflow input.
