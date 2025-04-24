

***

# 📄 Proxmox Windows 11 Setup with ISO and Ventoy USB

***

This guide walks you through expanding your Proxmox LVM, copying Windows 11 installation files, and accessing ISO files from a Ventoy-powered USB drive for VM installation.

***

# 🧱 Resize LVM in Proxmox
To reclaim space from the `/dev/pve/data` volume and allocate it to `/dev/pve/root`, follow these steps:
```bash
# bash

lvremove /dev/pve/data
lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/mapper/pve-root
```

***

# 💾 Prepare USB with Windows ISO
1. ✂️📋Copy the Windows 11 ISO to a USB Stick
You can use a tool like [Ventoy](https://www.ventoy.net/en/index.html) to boot directly from ISOs placed on the USB.

2. ⬇️ Download VirtIO Drivers
To ensure Windows recognizes the virtual hardware in Proxmox (especially disk and network adapters), download the VirtIO driver ISO:

***

# 🔗 Windows VirtIO Driver:

🔗 [Proxmox virtual environment wiki for Windows VirtIO Drivers - Main Page](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers)

🔗 [Windows VirtIO Driver Direct download link](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)

***

# 🔍 Detect and Mount Ventoy USB on Proxmox
1. List Attached Devices
Run this to identify the USB partitions:
```bash
# bash

lsblk
```

You'll likely see output like this EXAMPLE: 
```java
sdc     8:32   1 119.5G  0 disk 
├─sdc1  8:33   1 119.5G  0 part  ← Ventoy data partition (exFAT)
└─sdc2  8:34   1   32MB  0 part  ← Ventoy boot partition (vfat)
```

2. Mount the Correct Partition
Create a Mount Point:
```bash
# bash

mkdir -p /mnt/ventoy
```

3. Mount the Data Partition (sdc1):
```bash
# bash

mount /dev/sdc1 /mnt/ventoy
```

4. View Files on the USB:
```bash
# bash

ls -lh /mnt/ventoy
```

5. Copy the ISO file(s) fromm the usb to the Proxmox server:
```bash
# bash

cp /mnt/ventoy/windows_11_pro.iso /var/lib/vz/template/iso/
cp /mnt/ventoy/windows_virtualization_drivers.iso /var/lib/vz/template/iso/
```

6. Edit this file and the following two values if you are installing Proxmox on a laptop and you don't want the server to die when closing the lid:

**/etc/systemd/logind.conf**
```bash
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
```
![image](https://github.com/user-attachments/assets/18356c5b-e69f-476e-84ea-2691c961a015)

7. Restart the login service:
```bash
# bash

systemctl restart systemd-logind.service
```   

8. Edit this file and the following value if you are installing Proxmox on a laptop and you don't want the screen to burnout on the laptop:

**/etc/default/grub**
```bash
GRUB_CMDLINE_LINUX="consoleblank=300"
```
![image](https://github.com/user-attachments/assets/e035b2c8-c3d8-4433-9124-dd372ee642d0)

9. Update Grub
```bash
update-grub
```

10. safely eject - Umount USB:
```bash
# bash

umount -l /mnt/ventoy
```
