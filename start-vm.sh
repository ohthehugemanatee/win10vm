#!/bin/bash

# Sets up my host system and starts my Windows VM.
# set -eu
# if [ `whoami` != 'root' ]; then
#   echo "Must be run as root. Use sudo!"
#   exit 1
# fi


TOTAL_CORES='0-8'
TOTAL_CORES_MASK=FFF
HOST_CORES='0,7'
HOST_CORES_MASK=41
VIRT_CORES='1-6'

# when the console has exited, revert the core restrictions
cleanup() {
  echo "Resetting CPU cores"
  systemctl set-property --runtime -- user.slice AllowedCPUs=$TOTAL_CORES
  systemctl set-property --runtime -- system.slice AllowedCPUs=$TOTAL_CORES
  systemctl set-property --runtime -- init.scope AllowedCPUs=$TOTAL_CORES
  sysctl vm.stat_interval=1
  sysctl -w kernel.watchdog=1
  echo madvise  > /sys/kernel/mm/transparent_hugepage/enabled
  echo $TOTAL_CORES_MASK > /sys/bus/workqueue/devices/writeback/cpumask
}

trap "cleanup" EXIT

echo "Shielding VM..."

sync
echo 3 > /proc/sys/vm/drop_caches
echo 1 > /proc/sys/vm/compact_memory

systemctl set-property --runtime -- user.slice AllowedCPUs=$HOST_CORES     
systemctl set-property --runtime -- system.slice AllowedCPUs=$HOST_CORES
systemctl set-property --runtime -- init.scope AllowedCPUs=$HOST_CORES

sysctl vm.stat_interval=120
sysctl -w kernel.watchdog=0

echo $HOST_CORES_MASK > /sys/bus/workqueue/devices/writeback/cpumask
echo never > /sys/kernel/mm/transparent_hugepage/enabled

# Start the VM
/usr/bin/virsh start win10
# Start the VM console in a blocking way.
virt-viewer --connect qemu:///system win10

cleanup 
