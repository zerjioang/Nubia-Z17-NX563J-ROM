
# 0 :  filename
#$1 first param = img to unpack as absolute path
#$2 destination dir for unpacked files as absolute path

echo "	TARGET: " $1
echo "	DESTINATION: " $2

if [ -d $2 ]; then
	echo "		Destination dir already exists! unpacking aborted."
else
	mkdir -p $2
	cd $2
	abootimg -x $1
	#unpack ramdisk
	if [ -f "initrd.img" ]; then
		echo "		Unpacking content of .img ramdisk..."
		echo "		Creating output directory"
		mkdir ramdisk
		mv initrd.img initrd.gz
		echo "		Unpacking... [1/2]"
		gunzip initrd.gz
		ls
		cd ramdisk
		echo "		Unpacking [2/2]"
		cpio -idm < ../initrd
		echo "		Deleting old files..."
		rm ../initrd
		echo "		Unpacking done"
	else
		echo "		[ERROR] No ramdisk file found..."
	fi
fi

#abootimg --create (boot|recovery).img -f bootimg.cfg -k zImage -r initrd.img