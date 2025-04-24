
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

# 📄 Disable enterprise repo

# 🛠️ Edit this file /etc/apt/sources.list.d/pve-enterprise.list
Comment out the line by adding a # in front:
```bash
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
```
💾 Save and exit

***

# 📄 Enable the no-subscription repo:

# 🛠️ Edit this file /etc/apt/sources.list

Add this line at the bottom if it's not already there:
```bash
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```

***

# 🆕 Update the package list:
```bash
# bash

apt update
```

***

✅ Optional: Remove annoying update warnings in Web UI
To remove the red “No valid subscription” notice:
```bash
sed -i.bak "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
systemctl restart pveproxy
```
⚠️ Note: This gets overwritten with updates, so you might need to reapply after upgrades.
***

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

# 🛠️ Edit this file and the following value if you are installing Proxmox on a laptop and you don't want the screen to burnout on the laptop for being left on:
**/etc/default/grub**

Also while in the grub file you will want to Ensure IOMMU is enabled
```bash
GRUB_CMDLINE_LINUX="consoleblank=300"
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"
```
![image](https://github.com/user-attachments/assets/e035b2c8-c3d8-4433-9124-dd372ee642d0)

# ⬆️ Update Grub
```bash
# bash

update-grub
```

***

# 📦Install wsdd for Windows discorvery
```bash
# bash

apt update
sudo apt install wsdd
```

