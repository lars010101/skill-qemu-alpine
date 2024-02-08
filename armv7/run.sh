#!/bin/bash

DISK_NAME="alpine.armv7.qcow2"
PORT="2222"

# Run qemu
qemu-system-arm -accel tcg \
  -machine virt \
  -cpu cortex-a15 -smp cores=4 \
  -m 2048 \
  -bios AAVMF32_CODE.fd \
  -nographic \
  -drive if=virtio,id=hd,format=qcow2,file=$DISK_NAME \
  -nic user,hostfwd=tcp::$PORT-:22,model=virtio \
  -device virtio-rng-pci \
  -rtc base=utc,clock=host
