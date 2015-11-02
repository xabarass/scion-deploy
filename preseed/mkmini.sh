#!/bin/bash

BUILD_DIR="build"
MINI_ISO="$BUILD_DIR/mini.iso"
SCION_ISO="$BUILD_DIR/scion.iso"
EXTRACT_DIR="$BUILD_DIR/extract"

log() {
    echo "========> $@"
}

prereq() {
    local cmd="$1"
    local pkg="$2"
    if ! which "$cmd" &>/dev/null; then
        pkgs+=" $pkg"
    fi
}

pkgs=
prereq wget wget
prereq 7z p7zip-full
prereq genisoimage genisoiamge
prereq isohybrid syslinux

if [ -n "$pkgs" ]; then
    log "Installing missing packages:$pkgs"
    sudo apt-get install $pkgs || exit 1
fi

if [ ! -e "$MINI_ISO" ]; then
    log "Fetching mini.iso"
    wget -nv http://archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/current/images/netboot/mini.iso -O "$MINI_ISO"
fi

[ -e "$EXTRACT_DIR" ] && rm -r "$EXTRACT_DIR"

log "Extracting mini.iso"
7z x -o"$EXTRACT_DIR" "$MINI_ISO" > /dev/null || exit 1

log "Modifying initrd.gz"
gunzip -c "$EXTRACT_DIR/initrd.gz" > "$BUILD_DIR/initrd"
cp trusty.cfg "$BUILD_DIR/preseed.cfg"
cp find-non-cd "$BUILD_DIR"
printf "preseed.cfg\nfind-non-cd\n" | ( cd "$BUILD_DIR" && cpio -H newc -oAF "initrd"; )
gzip -c "$BUILD_DIR/initrd" > "$EXTRACT_DIR/initrd.gz"

cp isolinux.cfg "$EXTRACT_DIR/"
cp txt.cfg "$EXTRACT_DIR/"
rm -r "$EXTRACT_DIR/[BOOT]"

log "Creating custom ISO image"
genisoimage -r -J -l \
    -V "SCION Ubuntu 14.04 Install CD" \
    -b isolinux.bin -c boot.cat -no-emul-boot \
    -boot-load-size 4 -boot-info-table \
    -input-charset default \
    -o "$SCION_ISO" \
    "$EXTRACT_DIR"

log "Post-processing custom image with isohybrid"
isohybrid "$SCION_ISO"
