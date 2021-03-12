# My Windows 10 VM

These are my libvirt configurations for running a single Windows 10 VM on QEMU/KVM. I use this VM to do my day-to-day work, including lots of Office365 and Teams calls. Emphasis here is on performance and satisfying requirements for my workplace IT security, in a single VM environment.

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
3) Either enable 1GB hugepages, or remove the `<memoryBacking>` stanza from `win10.xml`.  To enable 1GB hugepages:
  * use the included `test-available-pagesize.sh` to check if your system will support 1GB hugepages.
  * add `hugepagesz=1G hugepages=8` to your kernel parameters in `/etc/default/grub.conf`
  * reboot
3) Define the XMLs in this repository for libvirt. `virsh define /path/to/this/repo/networks/default.xml` and then `virsh define /path/to/this/repo/win10.xml`.

At this point you can start the VM with `virt-manager` or `virsh` directly. If you want to use the CPU and memory optimizations, read on!

### CPU Affinity

The Libvirt configuration pins the qemu CPU, engine, and I/O threads to cores as specified in the XML, but it does not prevent system processes from running there. The easy way to do this:

1) Install `cpuset`, a python tool to simplify working with kernel cgroups.
2) Create a "shield" to move processes off of, and block new ones from starting on the threads reserved for the VM: `cset shield -c 1-6` (or whatever threads you use in you config)
2) Move kernel processes off the shielded threads: `cset shield --kthread on`.

When you're done with your VM you can get your threads back with `cset shield --reset`.


### HugePages

The Lbvirt configuration assigns the VM 8GB of RAM in contiguous 1GB blocks. Those blocks must be pre-allocated on the host before the VM starts, using the Linux "hugepages" system. If your kernel and CPU support hugepages (you can test this with the included `test-available-pagsize.sh` script), you could allocate those pages on the fly like this:

`echo 8 | sudo tee -a /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages`

Unfortunately, so many large blocks of contiguous memory are hard to come by. Even on my system with 32GB of RAM, after a bit of use this becomes impossible due to normal memory fragmentation. After running that command above, you can see how many hugepages the kernel managed to allocate by `cat`ing the same file.

If you want to use hugepages (and it's quite a nice performance boost!), here are your options:

1) Add that `echo` command to your vm startup script, and reboot your host every time you want to start a VM, or
2) Pre-allocate the 8 hugepages at boot time, reducing your host system's total RAM.

The most reliable way to pre-allocate those hugepages is in your grub configuration. Edit `/etc/default/grub.conf` and add `hugepagesz=1G hugepages=8` to your kernel parameters line, and reboot once. 

### Current benchmarks

Guest: (Novabench)
CPU: 917
RAM Score: 224
RAM Speed: 25314 MB/s
Disk: 288
Write Speed: 2799 MB/s
Read Speed: 2403 MB/s 
GPU: Fails to complete

### Performance improvements applied

* Pin vCPUs, IO threads, and emulator thread to physical cores. No difference until you are using majority of your cores for the VM
* Instructions for using cgroups to keep all other system tasks off of the VM cores
* virtio drivers for everything. This especially benefits from pinned IO cores.
* hyperV opions recommended for speed
* Raw disk image vs qcow2 (no difference on f2fs)
* Scaling CPU cores - best to have the majority of your cores assigned to the VM, to ensure the host's CPU frequency governor scales when the VM is under load. I have 6 of 8 cores in the VM.
* CPU in host-passthrough mode
* CPU threads selected to get maximum L2 cache (spread across as many cores as possible)
* CPU cache in passthrough mode
* Assign memory in 1GB hugepages
* Enable 3d acceleration on the virtio GPU, but not the spice display


### References

* [Arch wiki on libvirt](https://wiki.archlinux.org/index.php/Libvirt) - general explanation and basic performance tips
* [Setting up your VM with virtio drivers and SPICE](https://github.com/infokiller/win10-vm) - good guide to installing the fastest drivers available in a way that your IT organization will appreciate.
* [QEMU optimization from null src](https://null-src.com/posts/qemu-optimization/post.php) - very detailed article on optimization techniques I didn't find elsewhere, including cpu isolation with cgroups, changing your kernel scheduler, and other improvements.
* [RedHat Virtualization Tuning and Optimization guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_tuning_and_optimization_guide/index) - A great in-depth manual for optimization, although mostly aimed at the server use case. 
