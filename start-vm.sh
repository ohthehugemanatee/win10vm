#!/bin/sh

# Sets up my host system and starts my Windows VM.
set -eu
if [ `whoami` != 'root' ]; then
  echo "Must be run as root. Use sudo!"
  exit 1
fi
# when the console has exited, revert the system blockers.
cleanup() {
  echo "Failure detected; resetting CPU cores and memory"
  sudo cset shield --reset
  echo 0 | sudo tee -a /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
}
trap "cleanup" EXIT
# Use cgroups to "shield" cores 1-6 so only the VM can run on them.
cset shield -c 1-6 
# Move system processes off of the shielded cores.
cset shield --kthread on
# Allocate 8 x 1GB hugepages for the VM to use.
echo 8 | sudo tee -a /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
# Start the VM
/usr/bin/virsh start win10
# Start the VM console in a blocking way.
virt-viewer --connect qemu:///system win10

cleanup 

