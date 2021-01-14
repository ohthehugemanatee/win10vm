# My Windows 10 VM

These are my QEMU configurations for a Windows 10 VM on libvirt. Emphasis is given on performance and satisfying requirements for my workplace IT security.

Bare metal benchmark results using Phoronix are found in the root directory.

## To use

### Prerequisites
In order to use this config you must have already installed:

- `libvirtd` installed and running
- [spice server](https://www.spice-space.org/download.html#server)

You probably also want `virt-manager`, which includes a spice compatible viewer. All of this is available as packages for any major Linux distribution.

### Quick start

1) clone the repository
2) Create a disk image to use as your primary hard disk for the VM: `qemu-img create -f qcow2 -o size=60G my-vm-disk.img`. For better performance you may consider using `-f raw`, but you will lose features like snapshot, compression, etc.
2) Edit `win10.xml` and change lines 49-50 with the location and type of your disk image.
3) Define the XMLs in this repository for libvirt. `virsh define /path/to/this/repo/networks/default.xml` and then `virsh define /path/to/this/repo/win10.xml`.

At this point you can start the VM with `virt-manager` or `virsh` directly.


### Current benchmarks

Guest: (Novabench)
CPU: 683
RAM Score: 224
RAM Speed: 25314 MB/s
Disk: 288
Write Speed: 2799 MB/s
Read Speed: 2403 MB/s 
GPU: Fails to complete a 6 fps
