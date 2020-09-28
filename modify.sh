#!/bin/sh
sudo echo "Starting..."
MKSQSHFS4='./mksquashfs'
UNSQSHFS='./unsquashfs'
MKIMAGE='./mkimage'
case "$1" in
'extract'|'e')
offset1=`grep -oba hsqs $2 | grep -oP '[0-9]*(?=:hsqs)'`
offset2=`wc -c $2 | grep -oP '[0-9]*(?= )'`
size2=`expr $offset2 - $offset1`
#echo $offset1 " " $offset2 " " $size2
dd if=$2 of=kernel.bin bs=1 ibs=1 count=$offset1
dd if=$2 of=secondchunk.bin bs=1 ibs=1 count=$size2 skip=$offset1
sudo rm -rf squashfs-root 2>&1
sudo $UNSQSHFS -d squashfs-root secondchunk.bin
$MKIMAGE -l $2
rm secondchunk.bin
;;
'create'|'c')
sudo $MKSQSHFS4 ./squashfs-root ./newsecondchunk.bin
sudo chown $USER ./newsecondchunk.bin
cat kernel.bin newsecondchunk.bin > xxx.bin
#INFO=`$MKIMAGE -l kernel.bin`
#echo $INFO
Load_Address=`$MKIMAGE -l kernel.bin|awk -F":" '$1=="Load Address" {gsub(/ +/,"",$0);print $2}'`
Entry_Point=`$MKIMAGE -l kernel.bin|awk -F":" '$1=="Entry Point" {gsub(/ +/,"",$0);print $2}'`
Kernel_Ver=`$MKIMAGE -l kernel.bin|awk -F":" '$1=="Kernel Ver." {gsub(/ +/,"",$0);print $2}'`
FS_Ver=`$MKIMAGE -l kernel.bin|awk -F":" '$1=="FS Ver." {gsub(/ +/,"",$0);print $2}'`
Product_ID=`$MKIMAGE -l kernel.bin|awk -F":" '$1=="Product ID" {gsub(/ +/,"",$0);print $2}'`

SIZE=`wc -c kernel.bin | awk '{ print $1 }'`

dd if=xxx.bin of=tmp.bin bs=1 skip=64
$MKIMAGE -A mips -O linux -T kernel -C lzma -a $Load_Address -e $Entry_Point -k $SIZE -n $Product_ID -V $Kernel_Ver $FS_Ver -d tmp.bin $2
rm newsecondchunk.bin xxx.bin tmp.bin
#$MKIMAGE -l $2
;;
*)
echo 'run
"modify-firmware.sh extract firmware.bin"
You will find file "kernel.bin" and folder "squashfs-root".
Modify "squashfs-root" as you like,after everything is done,run
"modify-firmware.sh create newfirmware.bin"
And you will get a modified firmware named newfirmware.bin.
'
;;
esac

