
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
	$imgtool -x $1
fi