#!/bin/bash

ERROR=0
workdir_tools=$workdir/tools

clear; for x in `find -iname "*.odex"|sort`; do 
    odexFile=${x/\.\//}
    odex_dir=$(dirname $odexFile)
    echo "odex file dir is: $odex_dir"
    [ -e ${x/odex/jar} ] && source_apk_file=${odexFile/odex/jar} || source_apk_file=${odexFile/odex/apk} || source_apk_file=${odexFile/../../apk}
    source_apk_file=$(ls $odex_dir/../../*.apk)
    source_apk_file_name=$(basename $source_apk_file)

    #copy file to odexed_apps

    if [[ ! -d $workdir/unpack/system_img_unpacked/odexed_apps/ ]]; then
        mkdir -p $workdir/unpack/system_img_unpacked/odexed_apps/
    fi
    target_apk=$workdir/unpack/system_img_unpacked/odexed_apps/$source_apk_file_name
    cp -ra $source_apk_file /tmp/$source_apk_file_name

    echo "Source .apk file is: $source_apk_file"
    echo "Uncompiling $odexFile"
    echo "java -Xmx512m -jar $baksmalijar de -a 24 -d ./unpack/system_img_unpacked/system/framework/arm/ -d ./unpack/system_img_unpacked/system/framework/arm64/ $odexFile -o /tmp/odexfile_out"
    
    echo "
    Decompiling .odex...
    "
    java -Xmx512m -jar $baksmalijar de -a 24 -d ./unpack/system_img_unpacked/system/framework/arm/ -d ./unpack/system_img_unpacked/system/framework/arm64/ $odexFile -o /tmp/odexfile_out

    echo "
    Generating new .dex file...
    "
    if [ -e /tmp/odexfile_out ]; then
        echo "java -Xmx512m -jar $smalijar a -a 24 -o /tmp/assembled_odex.dex /tmp/odexfile_out"
        java -Xmx512m -jar $smalijar a -a 24 -o /tmp/assembled_odex.dex /tmp/odexfile_out
        ERROR=1
    fi

    echo "
    Adding .dex file to target .apk ( $target_apk )..
    "
    if [ -e /tmp/assembled_odex.dex ]; then
        mv /tmp/assembled_odex.dex /tmp/classes.dex
        cd /tmp/
        zip -q -g ./$source_apk_file_name ./classes.dex
        rm -rf /tmp/odexfile_out /tmp/assembled_odex.dex /tmp/classes.dex
    else
        rm -rf /tmp/odexfile_out /tmp/assembled_odex.dex /tmp/classes.dex
        ERROR=1
        echo "Error!"
    fi

    echo "
    Copying target file to source location...
    "
    echo "cp -ra /tmp/$source_apk_file_name $workdir/unpack/system_img_unpacked/odexed_apps/"
    cp -ra /tmp/$source_apk_file_name $workdir/unpack/system_img_unpacked/odexed_apps/
done

if [ $ERROR -eq 1 ]; then
    rm -rf *.odex
else
    echo "Error(s) detected. *.odex files not deleted."
fi