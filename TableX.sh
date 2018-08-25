#!/bin/sh

################################    Dependencias    #########################

clear
echo " Welcome to the creation script"
sleep 1
echo " of the linux image for an allwinner tablet "
sleep 1
echo " Installing dependancies"
sleep 1
#apt-get update
apt-get install -y flex bison gcc-arm-linux-gnueabihf wget bc tree git debootstrap qemu-system-arm qemu-user-static build-essential libssl-dev libusb-1.0-0-dev bin86 libqt4-dev libncurses5 libncurses5-dev qt4-dev-tools u-boot-tools device-tree-compiler swig libpython-dev libqt4-dev libusb-dev zlib1g-dev pkg-config libgtk2.0-dev libglib2.0-dev libglade2-dev
echo " Installation of dependencies completed "
sleep 1
echo " Creating directories and RAM disk "
sleep 1
################################   Creando directorios y disco RAM    #########################

mkdir /home/sunxi/
mkdir /home/sunxi/Imagen
mkdir /home/sunxi/tools
mkdir /home/sunxi/u-boot
mkdir /home/sunxi/kernel/
mkdir /home/sunxi/kernel/modules
mkdir /home/sunxi/kernel/mainline
mkdir /home/sunxi/kernel/zImage
mkdir /mnt/ramdisk
mkdir /TableX
clear
echo " Directories created "
################################   SUNXI-TOOLS    #########################
cp TableX_defconfig /home/sunxi
echo " OK "
sleep 1
echo " Installing sunxi-tools"
sleep 1
cd /home/sunxi/tools
git clone https://github.com/linux-sunxi/sunxi-tools
cd sunxi-tools
make -j$(nproc)
make -j$(nproc) install

echo " Installation completed"
sleep 1
################################   KERNEL LEGACY    #########################
#echo " Descargando Kernel sunxi"
#cd /home/sunxi/kernel/sunxi
#git clone https://github.com/linux-sunxi/linux-sunxi.git

################################   CREACIÓN DE IMAGEN ROOTFS    #########################
echo "      Rootfs location selection"
echo " Choose an option for the locatioin of the image "
sleep 2
echo "1. 	RAMdisk (Faster)"
echo ""
echo "2. 	Local, slower, advices to computers with low memery"
echo "Preparing Gnu/Linux Image"
echo ""
echo -n "	Select an option [1 - 2]"
read imagen
case $imagen in
1) mount -t tmpfs -o size=550M tmpfs /mnt/ramdisk && dd if=/dev/zero of=/mnt/ramdisk/trusty.img bs=1 count=0 seek=500M && mkfs.ext4 -b 4096 -F /mnt/ramdisk/trusty.img &&  chmod 777 /mnt/ramdisk/trusty.img && mount -o loop /mnt/ramdisk/trusty.img /TableX;;
2) dd if=/dev/zero of=/home/sunxi/Imagen/trusty.img bs=1 count=0 seek=500M && mkfs.ext4 -b 4096 -F /home/sunxi/Imagen/trusty.img &&  chmod 777 /home/sunxi/Imagen/trusty.img && mount -o loop /home/sunxi/Imagen/trusty.img /TableX;;
*) echo "$opc no es una opcion válida.";
echo "Press a key to continue ...";
read foo;;
esac
################################   DEBOOTSTRAP   #########################
debootstrap --arch=armhf --foreign trusty /TableX
################################   SCRIPT DE INICIO DE U-BOOT BOOT.SCR    #########################
echo " Adding start script "
> /home/sunxi/boot.cmd
cat <<+ >> /home/sunxi/boot.cmd
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p1 rootwait panic=10
load mmc 0:1 0x43000000 sun8i-a33-q8-tablet.dtb || load mmc 0:1 0x43000000 boot/sun8i-a33-q8-tablet.dtb
load mmc 0:1 0x42000000 zImage || load mmc 0:1 0x42000000 boot/zImage
bootz 0x42000000 - 0x43000000
+
mkimage -C none -A arm -T script -d /home/sunxi/boot.cmd /home/sunxi/boot.scr
cp /home/sunxi/boot.scr /TableX/boot
cp /home/sunxi/boot.cmd /TableX/boot
clear
echo " Completed"
sleep 1
################################   KERNEL   #########################
echo " Downloading and decompressing Kernel mainline" 
sleep 1
wget -P /home/sunxi/kernel/mainline https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.17.11.tar.xz
cd /home/sunxi/kernel/mainline/
tar -Jxf /home/sunxi/kernel/mainline/linux-4.17.11.tar.xz
cp /home/sunxi/TableX_defconfig /home/sunxi/kernel/mainline/linux-4.17.11/arch/arm/configs/
cd /home/sunxi/kernel/mainline/linux-4.17.11
echo " Compiling "
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf TableX_defconfig
# sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- xconfig
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs 
ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=/TableX make modules modules_install
cp -R lib /home/sunxi/kernel/modules
cp arch/arm/boot/zImage /TableX/boot/
cp arch/arm/boot/zImage  /home/sunxi/kernel/zImage
cd ..
clear
echo " Kernel compiled "
sleep 1
################################   U-BOOT   #########################
echo " Download and compilation of u-boot "
sleep 1
echo " Downloading u-boot denx "
sleep 1
cd /home/sunxi/u-boot
wget ftp://ftp.denx.de/pub/u-boot/u-boot-2017.11.tar.bz2 
wget ftp://ftp.denx.de/pub/u-boot/u-boot-2018.03.tar.bz2 
cp u-boot-2017.11.tar.bz2 /home/sunxi/u-boot
tar -xjvf u-boot-2017.11.tar.bz2
clear
echo " Download and decompression of finished u-boot "
sleep 1
echo " When the menu appears "
sleep 1
echo " you do not have to configure anything "
sleep 1
echo "To continue, select Menu ----> File ----> Quit"
sleep 1
cd u-boot-2017.11
echo "      U-boot compilation menu"
echo " Choose an option for compiling the u-boot according to your tablet model"
sleep 2
echo "1. 	Tablet a13 q8 "
echo ""
echo "2. 	Tablet a23 q8 Resolution 800x480"
echo ""
echo "3. 	Tablet a33 q8 Resolution 1024x600"
echo ""
echo "4. 	Tablet a33 q8 Resolution 800x480"
echo ""
echo "5. 	iNet_3F"
echo ""
echo "6. 	iNet_3W"
echo ""
echo "7. 	iNet_86VS"
echo ""
echo "8. 	iNet_D978"
echo ""
echo -n "	Select one opcion [1 - 8]"
read uboot
case $uboot in
1) sudo cp /home/sunxi/kernel/mainline/linux-4.17.11/arch/arm/boot/dts/sun5i-a13-q8-tablet.dtb /TableX/boot &&  make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- q8_a13_tablet_defconfig;;
2) sudo cp /home/sunxi/kernel/mainline/linux-4.17.11/arch/arm/boot/dts/sun8i-a23-q8-tablet.dtb /TableX/boot && make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- q8_a23_tablet_800x480_defconfig;;
3) sudo cp /home/sunxi/kernel/mainline/linux-4.17.11/arch/arm/boot/dts/sun8i-a33-q8-tablet.dtb /TableX/boot && make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- q8_a33_tablet_1024x600_defconfig;;
4) sudo cp /home/sunxi/kernel/mainline/linux-4.17.11/arch/arm/boot/dts/sun8i-a33-q8-tablet.dtb /TableX/boot && make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- q8_a33_tablet_800x480_defconfig;;
5) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- iNet_3F_defconfig ;;
6) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- iNet_3W_defconfig;;
7) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- iNet_86VS_defconfig;;
8) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- iNet_D978_rev2_defconfig;;
*) echo "$opc no es una opcion válida.";
echo "Press a key to continue ...";
read foo;;
esac
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
sudo cp u-boot-sunxi-with-spl.bin /TableX/boot
clear
echo "Compiled u-boot compilation"
sleep 1
echo "Starting deboostrap process"
sleep 1
################################   SCRIPT SEGUNDA PARTE DEBOOSTRAP   #########################
cp /usr/bin/qemu-arm-static /TableX/usr/bin
cp /usr/bin/qemu-system-common /TableX/usr/bin
cp /etc/resolv.conf /TableX/etc
> /home/sunxi/config.sh
cat <<+ >> /home/sunxi/config.sh
#!/bin/sh
echo " Configuring debootstrap second phase"
sleep 3
/debootstrap/debootstrap --second-stage
export LANG=C
echo "deb http://ports.ubuntu.com/ trusty main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Africa/Johannesburg" > /etc/timezone
echo "TableX" >> /etc/hostname
echo "127.0.0.1 TableX localhost
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" >> /etc/hosts
echo "auto lo
iface lo inet loopback" >> /etc/network/interfaces
echo "/dev/mmcblk0p1 /	   ext4	    errors=remount-ro,noatime,nodiratime 0 1" >> /etc/fstab
echo "tmpfs    /tmp        tmpfs    nodev,nosuid,mode=1777 0 0" >> /etc/fstab
echo "tmpfs    /var/tmp    tmpfs    defaults    0 0" >> /etc/fstab	
cat <<END > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
END
apt-get update
echo "Reconfiguring local parameters"
sleep 1
locale-gen en_ZA.UTF-8
export LC_ALL="en_ZA.UTF-8"
update-locale LC_ALL=en_ZA.UTF-8 LANG=en_ZA.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
dpkg-reconfigure -f noninteractive tzdata
apt-get upgrade -y
sudo apt-get install wireless-tools iw -y
rm -f /var/lib/dpkg/info/udev.post*
rm -f /var/lib/dpkg/info/udev.pre*
apt-get -f install
apt-get clean
adduser trusty
addgroup trusty sudo
+
chmod +x  /home/sunxi/config.sh
sudo cp  /home/sunxi/config.sh /TableX/home
echo "Mounting directories"
sleep 1
################################   MONTAJE DE PARTICIONES   #########################
sudo mount -o bind /dev /TableX/dev && sudo mount -o bind /dev/pts /TableX/dev/pts && sudo mount -t sysfs sys /TableX/sys && sudo mount -t proc proc /TableX/proc
################################   INICIO DE CHROOT DEBOOSTRAP SEGUNDA PARTE   ######
chroot /TableX /usr/bin/qemu-arm-static /bin/sh -i ./home/config.sh && exit 
################################   DESMONTAJE DE PARTICIONES Y SALIDA  #########################
rm /home/config.sh
sudo umount /TableX/dev/pts
sleep 3
sync
sudo umount /TableX/dev
sleep 3
sync
sudo umount /TableX/proc
sleep 3
sync
sudo umount /TableX/sys
sleep 3
sync
umount /TableX
exit
