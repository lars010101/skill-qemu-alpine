#!/bin/bash

VERSION=3.19.1
URL_EFI="http://ftp.de.debian.org/debian/pool/main/e/edk2/qemu-efi-arm_2023.11-5_all.deb"
URL_DISTR="https://dl-cdn.alpinelinux.org/alpine/v${VERSION:0:4}/releases/armv7/alpine-virt-$VERSION-armv7.iso"

DISK_NAME="alpine.armv7.qcow2"
DISK_SIZE="8G"

# Download Alpine
if [ ! -f $(basename $URL_DISTR) ]; then
	wget $URL_DISTR
fi

# Download efi for arm
if [ ! -f $(basename $URL_EFI) ]; then
	wget $URL_EFI
  dpkg -x $(basename $URL_EFI) tmp
  mv ./tmp/usr/share/AAVMF/AAVMF32_CODE.fd ./
  mv ./tmp/usr/share/AAVMF/AAVMF32_VARS.fd ./
  rm -rf tmp
  rm ${URL_EFI##*/} 
fi

# Create qemu disc
if [ ! -f "$DISK_NAME" ]; then
  qemu-img create -f qcow2 "$DISK_NAME" "$DISK_SIZE"
fi

# Run qemu
qemu-system-arm -accel tcg \
  -machine virt \
  -cpu cortex-a15 -smp cores=4 \
  -m 2048 \
  -bios AAVMF32_CODE.fd \
  -cdrom $(basename $URL_DISTR) \
  -drive format=qcow2,file=$DISK_NAME \
  -nographic \
  -nic user,model=virtio \
  -rtc base=utc,clock=host
