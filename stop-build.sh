#!/bin/bash
# Stop all BitBake build sessions and clean up stale files

echo "Stopping all BitBake processes..."
pkill -TERM -f 'bitbake' 2>/dev/null
sleep 2
pkill -KILL -f 'bitbake' 2>/dev/null
pkill -KILL -f 'pseudo' 2>/dev/null

echo "Cleaning up stale lock and socket files..."
rm -f /home/pk-sdv/sandboxes/yocto_build/build-raspberrypi5/bitbake.lock
rm -f /home/pk-sdv/sandboxes/yocto_build/build-raspberrypi5/bitbake.sock
rm -f /home/pk-sdv/sandboxes/yocto_build/build-raspberrypi5/bitbake.sock2
rm -f /home/pk-sdv/sandboxes/yocto_build/build-raspberrypi5/hashserve.sock

rm -f /home/pk-sdv/sandboxes/yocto_build/build-raspberrypi4/bitbake.lock
rm -f /home/pk-sdv/sandboxes/yocto_build/build-raspberrypi4/bitbake.sock
rm -f /home/pk-sdv/sandboxes/yocto_build/build-raspberrypi4/bitbake.sock2
rm -f /home/pk-sdv/sandboxes/yocto_build/build-raspberrypi4/hashserve.sock

echo "Build session stopped."
ps aux | grep -E 'bitbake|pseudo' | grep -v grep && echo "WARNING: Some processes still running" || echo "All processes cleaned up."
