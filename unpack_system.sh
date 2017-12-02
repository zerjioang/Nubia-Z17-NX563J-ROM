
# 0 :  filename
#$1 transfer list
#$2 system.dat file 
#$3 out dir img file
out=$3
system_img_file=$out"/system.img"
system_folder_out=$out"/system"
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
	if [ -f $system_img_file ]; then
		echo "System.img found! Unpacking aborted."
	else
		#convert
		$workdir"/tools/sdat2img/sdat2img.py" $1 $2
	fi
fi

#mount system.img
if [ -f $system_img_file ]; then
	file $system_img_file

	#create sysmte folder
	if [ -d $system_folder_out ]; then
		echo "Creating output folder..."
		mkdir -p $system_folder_out
	fi

	if [[ ! -f filelist.txt ]]; then
		#statements
		echo "We need sudo access to mount system.img in your system"
		echo "system.img will be mounted on: "$mountDir

		#mount filesystem img
		echo sudo mount -t ext4 -o loop,rw $system_img_file $mountDir
		sudo mount -t ext4 -o loop,rw $system_img_file $mountDir

		echo "Copying mounted file content to $system_folder_out"
		sudo cp -ra $mountDir $system_folder_out

		echo "Setting current user ownership"
		sudo chown $USER -R $system_folder_out

		echo "unmount target dir $mountDir"
		sudo umount $mountDir

		nautilus $system_folder_out &

		#generate filelist
		sudo du -ah $system_folder_out | grep -v "/$" | sort -rh > filelist.txt
	else
		echo "System folder already unpacked at ./system "
	fi
	#open in sublime 
	#sudo subl $system_folder_out
else
	echo "No system.img found"
fi