
# 0 :  filename
#$1 transfer list
#$2 system.dat file 
#$3 out dir img file
out=$3
dest=$out"/system.img"
mountDir=$out"/mount"

echo "	TARGET TRANSFER LIST: " $1
echo "	TARGET SYSTEM DAT: " $2
echo "	DESTINATION: " $out

#check if exists mount folder
if [ -d $mountDir ]; then
	echo "		Mount dir already exists!"
else
	#create mount folder
	mkdir -p $mountDir
fi

if [ -d $2 ]; then
	echo "		Destination dir already exists! unpacking aborted."
else
	#create output file if not
	if [ -d $out ]; then
		echo "		output dir exists"
	else
		mkdir -p $out
	fi

	#go to destination folder
	cd $3
	#check if system.img exists
	if [ -f $dest ]; then
		echo "System.img found! Unpacking aborted."
	else
		#convert
		$workdir"/tools/sdat2img/sdat2img.py" $1 $2
	fi
fi

#mount system.img
if [ -f $dest ]; then
	file $dest
	echo "We need sudo access to mount system.img in your system"
	echo "system.img will be mounted on: "$mountDir
	echo sudo mount -t ext4 -o loop,rw $dest $mountDir
	sudo umount $mountDir
	sudo mount -t ext4 -o loop,rw $dest $mountDir
	sudo nautilus $mountDir &
	cd $workdir
	#generate filelist
	sudo du -ah $mountDir | grep -v "/$" | sort -rh > filelist.txt
	#open in sublime 
	sudo subl $mountDir
else
	echo "No system.img found"
fi