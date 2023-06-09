The content of the file is derived from contributions by [Zangman](https://github.com/zangman/de10-nano/blob/master/docs/Setting-up-the-Development-Environment.md) and [VHDLWhiz](https://vhdlwhiz.com/modelsim-quartus-prime-lite-ubuntu-20-04/) repositories.

# Summary

Here we will take some time to set up our development environment. This environment will be similar to what was used for creating this guide. This will ensure that:

- All the commands used in this guide work seamlessly.
- You can close your session and/or restart your terminal without having to do the set up again.

## Operating System

We will use Debian as the main OS for everything. At the time of writing this guide, buster is the latest version of Debian. A complete list of Debian releases can be viewed in the [Index of releases](https://www.debian.org/releases/#:~:text=for%20detailed%20information.-,Index%20of%20releases,-The%20next%20release). I strongly recommend using Debian for your development environment, it will save you a fair bit of time debugging and makes it easier to follow along with all the commands.

This guide does not go into the details of installing Debian, there are plenty of resources available online. You can use [virtualbox](https://www.virtualbox.org/) as well if you don't have a dedicated Debian machine. That's what I used.

### Important: Storage space

I would suggest having at least 200 GB of disk space available when starting out. You can probably get away with 100 GB, but it's better to have a buffer. FPGA software and building a working Linux distro requires a fair bit of space. If you are using virtualbox and don't currently have that amount of space, I would suggest that you make the space available before you begin rather than resizing it later. This will save a bit of hassle.

Proceed to the next step after you have a working Debian install. If you are using virtualbox, make sure you have Virtualbox Guest Additions installed so that you can have full screen working.

### Setting up sudo

Typically Debian doesn't setup sudo for you and I prefer to use sudo rather than run commands as a root user. This guide assumes sudo is already enabled and setup, but if not [Google is your friend](https://www.google.com/search?q=debian+setup+sudo).

You can also choose not to use sudo. Simply run the command `su` to become root and run the command without `sudo`.

## Quartus Download and Install

The following software is needed. All the tools are free, but you will need to create an account in order to download. The software can be obtained from [Intel's FPGA Software Download Center](https://www.intel.com/content/www/us/en/software-kit/661017/intel-quartus-prime-lite-edition-design-software-version-20-1-for-linux.html).

This guide will use version 20.1. Choose to download "Indivual files" and select:

- Quartus Prime Lite Edition
  - ModelSim-Intel FPGA Edition (includes Starter Edition)    (Required for design simulation)
  - Cyclone V device support

The Intel SoC FPGA Embedded Development Suite Standard Edition can be downloaded from [Intel's FPGA Software Download Center](https://www.intel.com/content/www/us/en/software-kit/661080/intel-soc-fpga-embedded-development-suite-soc-eds-standard-edition-software-version-20-1-for-linux.html) as well.


Quartus Prime installer can install the other tools as well if they are all present in the same directory. So it is advisable to wait until all the files are downloaded before you install them.

Once downloaded, you will need to make the installer executable. I downloaded all the files into `~/Downloads/quartus_downloads`. Modify the commands below accordingly depending on where you downloaded the files.

```bash
cd ~/Downloads/quartus_downloads/
chmod +x *.run

# Install Quartus Prime. Replace this with the version you downloaded.
# This takes few mins to complete.
# The default install location is fine i.e. ~/intelFPGA_lite
./QuartusLiteSetup-20.1.0.711-linux.run

# Once it completes, install EDS.
# Make sure to change the install location from ~/intelFPGA to ~/intelFPGA_lite.
./SoCEDSSetup-20.1.0.711-linux.run
```

Let's edit `.bash_aliases` so that we the quartus tools are easily accessible:

```bash
echo "" >> ~/.bash_aliases
echo "# Path for Quartus tools." >> ~/.bash_aliases

# Access to quartus, qsys etc.
echo "export PATH=$HOME/intelFPGA_lite/20.1/quartus/bin:\$PATH" >> ~/.bash_aliases

# Access to embedded_command_shell.sh which sets up the
# environment variables so that all the embedded tools are available
# like bsp-settings-editor etc.
echo "export PATH=$HOME/intelFPGA_lite/20.1/embedded:\$PATH" >> ~/.bash_aliases
```

### Access USB Blaster
If you'd like to use the Programmer available in the Tools menu in Quartus, then you need to change the permissions for the usb device to be accessible to everyone.

After connecting the cable to your machine, run `lsusb` to list all the usb devices:

```bash
~ > lsusb
...
Bus 001 Device 013: ID 09fb:6810 Altera
...
~ >
```

We need to set up a udev rule for this as follows. Create a new file as follows:

```bash
sudo gedit /etc/udev/rules.d/51-usbblaster.rules
```

Paste the following after replacing the values correspondingly from `lsusb`:

```bash
# USB Blaster II
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666", NAME="bus/usb/$env{BUSNUM}/$env{DEVNUM}", RUN+="/bin/chmod 0666 %c"
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666", NAME="bus/usb/$env{BUSNUM}/$env{DEVNUM}", RUN+="/bin/chmod 0666 %c"

```

Save the file and exit. Restart your machine and the device should now be accessible to all users.

However, it is possible to reassign rights in this way (change bus and device number as needed): 
```bash
sudo chmod 666 /dev/bus/usb/001/013
```

This completes the Quartus section of the setup.

## Working Directory

I prefer to be organized. And we'll be working with a very large number of files and directories, so it's better to keep things organized from the beginning.

Let's create a dedicated working directory for this project and make sure we always have it available. You can call it whatever you like, I will call mine `de10nano-wd`:

```bash
cd
mkdir de10nano-wd
export DEWD=$PWD/de10nano-wd

# Add it to bash_aliases so that we don't have to do this everytime.
echo "" >> ~/.bash_aliases
echo "# DE10-Nano working directory" >> ~/.bash_aliases
echo "export DEWD=$PWD/de10nano-wd" >> ~/.bash_aliases
```

## ARM Compiler

The DE10-Nano has an ARM Cortex A9 HPS processor. Your Debian install probably has an i686 processor. The compilers for both are not compatible. So when compiling the kernel or writing programs for the HPS on your Debian desktop, you will need to use a compatible compiler. Otherwise it will fail.

Here we will set up the environment to use the Linaro GCC to enable cross compiling.

> **Did you know?**
>
> Cross compiling is the term used when you are compiling programs for one architecture (ARM in this case) on another architecture (i686 in our case)

### Get a suitable ARM compiler

Head over to the [downloads page at Linaro](https://www.linaro.org/downloads/) and download the latest binary release for `arm-linux-gnueabihf`. This is the version of `gcc` that we will use to compile our kernel with. The latest version at the time of writing is `7.5.0-2019.12`. We will fetch the `x86_64` release because we're using Debian on a 64-bit machine.

```bash
cd $DEWD
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf.tar.asc

tar -xf gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf.tar.asc

# Delete the archive since we don't need it anymore.
rm gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf.tar.asc
```

Set the `CROSS_COMPILE` environment variable to point to the binary location. This is to tell the kernel `Makefile` where the compiler binary is located.

```bash
export CROSS_COMPILE=$DEWD/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-
```

With this step, we are done. However, if we close the current terminal or restart the machine, we will lose the `CROSS_COMPILE` environment variable and will have to set it up again. To avoid this, let's add this to `~/.bash_aliases` so that it gets set up every time we open a new shell.

Run the following commands while in the same directory:

```bash
echo "" >> ~/.bash_aliases
echo "# Cross compiler for DE10-Nano." >> ~/.bash_aliases
echo "export CROSS_COMPILE=$DEWD/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-" >> ~/.bash_aliases
```

> **Did you know?**
>
> This is a very clever way of making sure the same command can be used for multiple architectures.
>
> ```bash
> ${CROSS_COMPILE}gcc
> ```
>
> If `CROSS_COMPILE` is not set, then it uses the system default `gcc`. If it is set, it uses the version specified by the variable.

## Enable ModelSim - free version
The ModelSim version that comes with Intel Quartus Prime Lite Edition is a good alternative if youwant to try out VHDL simulation on your home computer. The software is available for bothWindows and Linux.  Unfortunately, the free version is a 32-bit application and supposing you have a 64-bit OS, dependencies must be satisfied adding 32-bit version of required libraries. For your convenience, a resume of the procedure is in the following.

```bash
# Open a terminal in your home directory
  
# Update your system
sudo apt update; sudo apt upgrade
  
# Make the vco script writable
chmod u+w ~/intelFPGA_lite/*.*/modelsim_ase/vco
  
# Make a backup of the vco file
(cd ~/intelFPGA/*.*/modelsim_ase/ && cp vco vco_original)
  
# Edit the vco script manually, or with these commands:
sed -i 's/linux\_rh[[:digit:]]\+/linux/g' \
    ~/intelFPGA_lite/*.*/modelsim_ase/vco
sed -i 's/MTI_VCO_MODE:-""/MTI_VCO_MODE:-"32"/g' \
    ~/intelFPGA_lite/*.*/modelsim_ase/vco
sed -i '/dir=`dirname "$arg0"`/a export LD_LIBRARY_PATH=${dir}/lib32' \
    ~/intelFPGA_lite/*.*/modelsim_ase/vco
  
 
# Download the 32-bit libraries and build essentials
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install build-essential
    sudo apt install gcc-multilib g++-multilib lib32z1 \
    lib32stdc++6 lib32gcc1 libxt6:i386 libxtst6:i386 expat:i386 \
    fontconfig:i386 libfreetype6:i386 libexpat1:i386 libc6:i386 \
    libgtk-3-0:i386 libcanberra0:i386 libice6:i386 libsm6:i386 \
    libncurses5:i386 zlib1g:i386 libx11-6:i386 libxau6:i386 \
    libxdmcp6:i386 libxext6:i386 libxft2:i386 libxrender1:i386
  
# Download the old 32-bit version of libfreetype
wget https://ftp.osuosl.org/pub/blfs/conglomeration/freetype/freetype-2.4.12.tar.bz2
tar xjf freetype-2.4.12.tar.bz2
  
# Compile libfreetype
cd freetype-2.4.12/
./configure --build=i686-pc-linux-gnu "CFLAGS=-m32" \
    "CXXFLAGS=-m32" "LDFLAGS=-m32"
make clean
make
  
cd ~/intelFPGA_lite/*.*/modelsim_ase/
mkdir lib32
cp ~/freetype-2.4.12/objs/.libs/libfreetype.so* lib32/
  
# Run the vsim script to start ModelSim
cd
~/intelFPGA_lite/*.*/modelsim_ase/bin/vsim
```
