#!/bin/bash

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
	if [[ ! -d $workdir//unpack/system_img_unpacked/system ]]; then
		system_img_unpack_dir=$workdir"/unpack/system_img_unpacked"
		bash unpack_system.sh $unzipDir"/system.transfer.list" $unzipDir"/system.new.dat" $system_img_unpack_dir
	else
		echo "system folder found. skipping system.img unpack"
	fi
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

deodex_rom(){
	echo "Deoxing ROM..."
	cd $workdir
	echo "bash ./deodex.sh $smalijar $baksmalijar"
	bash ./deodex.sh
}

decompile_apks(){
	echo "Decompiling APKs..."
	cd $workdir
	cd unpack/system_img_unpacked/
	list=$(find ./odexed_apps/ -name "*.apk")
	echo "-----"
	echo "APK LIST"

	if [[ ! -d decompiled_apps ]]; then
		#statements
		mkdir decompiled_apps
	fi

	framework_files_dir=./decompiled_apps/framework
	if [[ ! -f decompiled_apps/framework/1.apk ]]; then
		#find ROM framework files
		local framework_apk_list=$(find ./system/ -name "framework*.apk")
		
		#create framework folder if does not exists
		if [[ ! -d $framework_files_dir ]]; then
			mkdir -p $framework_files_dir
		fi

		#install frameworks using apktool
		echo "Installing ROM frameworks..."
		#decompile all apps
		for f in $framework_apk_list
		do
		    echo "Installing framework file $f in $framework_files_dir..."
		    file $f
		    echo "apktool if -p $framework $f"
			apktool if -p $framework_files_dir $f
		done
	else
		echo "framework already setup"
	fi

	#decompile all apps
	for app in $list
	do
	    echo $app
	    file $app
	    apk_unpack $app $framework_files_dir
	done
}

apk_unpack(){
	apk=$1
	framework_path=$2
	local output_folder=$workdir/unpack/system_img_unpacked/decompiled_apps/apps/
	folder_name=$(basename $apk)

	if [[ ! -d $output_folder/$folder_name ]]; then
		#folder does not exists. not decompiled yet
		echo "Unpacking folder is: $folder_name"
		echo "apktool d -o $output_folder -p $framework_path $apk"
		apktool d -o $output_folder/$folder_name -p $framework_path $apk
		#gnome-terminal -x bash -c "apktool d -o $output_folder/$folder_name -p $framework_path $apk | ccze"
	else
		echo "$folder_name already decompiled. skipping..."
	fi
}

decompile_jars(){
	echo "Decompiling JARs..."

	cd $workdir
	cd unpack/system_img_unpacked/

	jarlist=$(find ./system/ -name "*.jar")

	if [[ ! -d decompiled_jars ]]; then
		#statements
		mkdir decompiled_jars
	fi

	#decompile all jar
	for jar in $jarlist
	do
	    echo $jar
	    file $jar
	    jar_name=$(basename $jar)
	    out=$(pwd)/decompiled_jars/$jar_name
	    jar_unpack $jar $out
	done
}

jar_unpack(){
	jarpath=$1
	out=$2
	echo "Decompiling jar: $jarpath"
	echo java -jar $procyon -jar $jarpath -o $out
	java -jar $procyon -jar $jarpath -o $out
}

init(){
	reset
	requirements

	if [[ ! -d $workdir//unpack/system_img_unpacked/system ]]; then
		echo "Reading ROM file..."
		read_rom
		echo "Unzipping ROM file..."
		unzip_rom
		echo "Unpacking ROM img files..."
		unpack_rom
	else
		echo "system folder found. skipping ROM unpack"
	fi

	if [[ ! -d $workdir//unpack/system_img_unpacked/odexed_apps ]]; then
		echo "Deodexing ROM internal files..."
		deodex_rom
	else
		echo "ROM apps already deodexed. skipping..."
	fi
	
	if [[ ! -d $workdir//unpack/system_img_unpacked/decompiled_apps/apps ]]; then
		echo "Decompiling ROM internal apk files..."
		decompile_apks
	else
		echo "ROM apps already decompiled. skipping..."
	fi

	if [[ ! -d $workdir//unpack/system_img_unpacked/decompiled_jars ]]; then
		echo "Decompiling ROM internal jar files..."
		decompile_jars
	else
		echo "ROM jars already decompiled. skipping..."
	fi
}

create_dir(){
	cd $workdir
	if [ -d $1 ]; then
		echo "	[ SKIP ] $1 source dir already exists."
	else
		mkdir -p $workdir"/"$1
	fi
}

downloadifnot(){
	folder=$2
	if [[ ! -d $folder ]]; then
		#download folder if does not exists
		$($1)
	fi
}

requirements(){
	#create dirs if not found
	create_dir "source"
	create_dir "unpack"
	create_dir "unzip"
	create_dir "tools"

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
	imgtool_path=$workdir/tools/imgtool
	if [[ -d $imgtool_path ]]; then
	    echo '[ SKIP ] imgtool FOUND. skipping...'
	else
	    echo '[imgtool] NOT FOUND. Installing...'
	    cd $workdir/tools
	    mkdir imgtool
	    wget 'http://newandroidbook.com/files/imgtool.tar'
	    tar -xvf imgtool.tar -C ./imgtool && rm imgtool.tar && cd imgtool
	    echo "imgtool location = "$workdir"/tools/imgtool/imgtool.ELF64"
	    export imgtool=$workdir"/tools/imgtool/imgtool.ELF64"
	fi

	cd $workdir/tools
	downloadifnot "git clone https://github.com/xpirt/img2sdat" img2sdat
	downloadifnot "git clone https://github.com/xpirt/sdat2img" sdat2img

	if [[ ! -d apktool ]]; then
		cd $workdir/tools
		mkdir apktool
		cd apktool
		echo "Downloading apktool..."
		wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
		wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.3.0.jar
		mv apktool_2.3.0.jar apktool.jar
		echo "Setting execution permissions..."
		chmod +x apktool
		echo "Copying to usr/bin..."
		sudo cp -ra apktool /usr/bin/apktool
		sudo cp -ra apktool.jar /usr/bin/apktool.jar
	fi

	if [[ ! -d procyon ]]; then
		cd $workdir/tools
		mkdir procyon
		cd procyon
		echo "Downloading procyon..."
		wget https://bitbucket.org/mstrobel/procyon/downloads/procyon-decompiler-0.5.30.jar
		export procyon=$(pwd)/procyon-decompiler-0.5.30.jar
	fi

	if [[ ! -d smali ]]; then
		cd $workdir/tools
		mkdir smali
		cd smali
		echo "Downloading smali..."
		wget https://bitbucket.org/JesusFreke/smali/downloads/smali-2.2.2.jar
	fi
	export smalijar=$workdir/tools/smali/smali-2.2.2.jar

	if [[ ! -d baksmali ]]; then
		cd $workdir/tools
		mkdir baksmali
		cd baksmali
		echo "Downloading baksmali..."
		wget https://bitbucket.org/JesusFreke/smali/downloads/baksmali-2.2.2.jar
	fi
	export baksmalijar=$workdir/tools/baksmali/baksmali-2.2.2.jar
}

export workdir=$(pwd)
init