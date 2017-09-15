
#-r read only variable
#-i integer variable
#-a array variable
#-f for funtions
#-x declares and export to subsequent commands via the environment.

unpack_rom(){
	cd $workdir
	#unpack boot.img
	boot_img_unpack_dir=$workdir"/unpack/boot_img_unpacked"
	bash unpack_img.sh $unzipDir"/boot.img" $boot_img_unpack_dir

	#unpack recovery.img
	recovery_img_unpack_dir=$workdir"/unpack/recovery_img_unpacked"
	bash unpack_img.sh $unzipDir"/recovery.img" $recovery_img_unpack_dir

	#unpack splash.img
	splash_img_unpack_dir=$workdir"/unpack/splash_img_unpacked"
	bash unpack_splash.sh $unzipDir"/splash.img" $splash_img_unpack_dir

	#unpack system.new.dat
	system_img_unpack_dir=$workdir"/unpack/system_img_unpacked"
	bash unpack_system.sh $unzipDir"/system.transfer.list" $unzipDir"/system.new.dat" $system_img_unpack_dir
}

read_rom(){
	cd $workdir
	cd ./source
	export base_filename=$(ls)
	echo "	ROM zip files is: 	"$base_filename
	export romzip=$workdir'/source/'$base_filename
	echo "	Reading filetype..."
	file $romzip
	export unzipDir=$workdir'/unzip'
}

unzip_rom(){
	cd $workdir
	if [ -d "unzip/META-INF" ]; then
		echo "	--> ROM already unzipped. SKIP"
	else
		unzip $romzip -d $unzipDir
	fi
}

init(){
	clear
	requirements

	echo "Reading ROM file..."
	read_rom
	echo "Unzipping ROM file..."
	unzip_rom
	echo "Unpacking ROM img files..."
	unpack_rom
}

requirements(){
	#create dirs if not found
	cd $workdir
	if [ -d "source" ]; then
		echo "source dir already exists. Aborting"
	else
		mkdir -p $workdir"/source"
	fi
	if [ -d "unpack" ]; then
		echo "unpack dir already exists. Aborting"
	else
		mkdir -p $workdir"/unpack"
	fi
	if [ -d "unzip" ]; then
		echo "unzip dir already exists. Aborting"
	else
		mkdir -p $workdir"/unzip"
	fi

	if [ -d "tools" ]; then
		echo "tools dir already exists. Aborting"
	else
		mkdir -p $workdir"/tools"
	fi

	echo "."
	echo " CHECKING DEPENDENCIES..."
	echo "."
	#install needed dependencies
	if which abootimg >/dev/null; then
	    echo '[abootimg] FOUND. skipping...'
	else
	    echo '[abootimg] NOT FOUND. Installing...'
	    sudo apt install abootimg
	fi

	##check imgtool
	if which imgtool >/dev/null; then
	    echo '[imgtool] FOUND. skipping...'
	else
	    echo '[imgtool] NOT FOUND. Installing...'
	    cd $workdir
	    cd tools
	    mkdir imgtool
	    wget 'http://newandroidbook.com/files/imgtool.tar'
	    tar -xvf imgtool.tar -C ./imgtool && rm imgtool.tar && cd imgtool
	    echo "imgtool location = "$workdir"/tools/imgtool/imgtool.ELF64"
	    export imgtool=$workdir"/tools/imgtool/imgtool.ELF64"
	fi

	cd $workdir
	cd tools
	git clone https://github.com/xpirt/img2sdat
	git clone https://github.com/xpirt/sdat2img
}

export workdir=$(pwd)
init