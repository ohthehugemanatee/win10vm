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
2) Edit `win10.xml` and change lines 49-50 with the location and type of your disk image, and lines 20-29 (`cputune`) and 49 (`topology`) to match the physical topology of your CPU.
3) Define the XMLs in this repository for libvirt. `virsh define /path/to/this/repo/networks/default.xml` and then `virsh define /path/to/this/repo/win10.xml`.

At this point you can start the VM with `virt-manager` or `virsh` directly.


### Current benchmarks

Guest: (Novabench)
CPU: 917
RAM Score: 224
RAM Speed: 25314 MB/s
Disk: 288
Write Speed: 2799 MB/s
Read Speed: 2403 MB/s 
GPU: Fails to complete a 6 fps

### Performance improvements applied

* Pin vCPUs, IO threads, and emulator thread to physical cores. No difference until you are using majority of your cores for the VM
* virtio drivers for everything. This especially benefits from pinned IO cores.
* hyperV opions recommended for speed
* Raw disk image vs qcow2 (no difference on f2fs)
* Scaling CPU cores - best to have the majority of your cores assigned to the VM, to ensure the host's CPU frequency governor scales when the VM is under load. I have 6 of 8 cores in the VM.
* CPU in host-passthrough mode
