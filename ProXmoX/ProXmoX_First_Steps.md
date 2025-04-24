#

Create a new mount point (optional but clean):

bash
Copy
Edit
mkdir -p /mnt/ventoy
Mount just the data partition (sdc1):

bash
Copy
Edit
mount /dev/sdc1 /mnt/ventoy
View your files:

bash
Copy
Edit
ls -lh /mnt/ventoy
You should now see all the ISO files you copied (like windows11.iso, etc.).
