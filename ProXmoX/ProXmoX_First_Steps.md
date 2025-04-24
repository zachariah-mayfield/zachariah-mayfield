#

### Create a new mount point:
mkdir -p /mnt/ventoy


### Mount just the data partition (sdc1):
mount /dev/sdc1 /mnt/ventoy


### View your files:
ls -lh /mnt/ventoy


### You should now see all the ISO files you copied (like windows11.iso, etc.).
