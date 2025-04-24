# 📄 Proxmox Initial Setup on a Laptop
This guide walks you through expanding your Proxmox LVM

# 🧱 Resize LVM in Proxmox
To reclaim space from the `/dev/pve/data` volume and allocate it to `/dev/pve/root`, follow these steps:
```bash
# bash

lvremove /dev/pve/data
lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/mapper/pve-root
```

# 🛠️ Edit this file and the following two values if you are installing Proxmox on a laptop and you don't want the server to die when closing the lid:

**/etc/systemd/logind.conf**
```bash
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
```
![image](https://github.com/user-attachments/assets/18356c5b-e69f-476e-84ea-2691c961a015)

# 🔄 Restart the login service:
```bash
# bash

systemctl restart systemd-logind.service
```   

# 🛠️ Edit this file and the following value if you are installing Proxmox on a laptop and you don't want the screen to burnout on the laptop:

**/etc/default/grub**
```bash
GRUB_CMDLINE_LINUX="consoleblank=300"
```
![image](https://github.com/user-attachments/assets/e035b2c8-c3d8-4433-9124-dd372ee642d0)

# ⬆️ Update Grub
```bash
update-grub
```
