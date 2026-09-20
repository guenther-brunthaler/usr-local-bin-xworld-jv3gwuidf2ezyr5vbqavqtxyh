#! /bin/false

# Make sure we are *really* running from within an initramfs!
#
# v2026.262

stat -f . | grep -q "Type: ramfs" || dry_run=true
