# Reverse engineering of splash.img

Lets se whats inside of splash.img
```
$ sha256sum splash.img

01b5acdb1c6ef47e54765dac2c83f9f9140ab1334cd99aae08774caff76cd96f  splash.img

$ file splash.img

splash.img: data

$ binwalk splash.img

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
16384         0x4000          PC bitmap, Windows 3.x format,, 1080 x 1920 x 24
```

Lets extract inside Bitmap file

```
$ binwalk --dd='.*' splash.img
cd _splash.img.extracted/
file 4000
4000: PC bitmap, Windows 3.x format, 1080 x 1920 x 24
```

## Converting PC Bitmap to splash.img

```
git clone https://github.com/poliva/nbimg
cd nbimg
make
./nbimg 

=== nbimg v1.2.1
=== Convert IMG/NB <--> BMP splash screens
=== (c)2007-2012 Pau Oliva - pof @ xda-developers

Usage: nbimg -F file.[nb|bmp|img]

Mandatory arguments:
   -F <filename>    Filename to convert.
                    If the extension is BMP it will be converted to NB/IMG.
                    If the extension is NB/IMG it will be converted to BMP.

Optional arguments:
   -w <width>       Image width in pixels. If not specified will be autodetected.
   -h <height>      Image height in pixels. If not specified will be autodetected.
   -t <pattern>     Manually specify the padding pattern (usually 0 or 255).
   -p <size>        Manually specify the padding size.
   -n               Do not add HTC splash signature to NB file.
   -s               Output smartphone format (for old WinCE devices).

NBH arguments:      (only when converting from BMP to NBH)
   -D <model_id>    Generate NBH with specified Model ID (mandatory)
   -S <chunksize>   NBH SignMaxChunkSize (64 or 1024)
   -T <type>        NBH header type, this is typically 0x600 or 0x601

mv ../_splash.img.extracted/4000 ../_splash.img.extracted/4000.BMP

./nbimg -F ../_splash.img.extracted/4000.BMP -w 1080 -h 1920 -p 16384 -n

=== nbimg v1.2.1
=== Convert IMG/NB <--> BMP splash screens
=== (c)2007-2012 Pau Oliva - pof @ xda-developers

[] File: ../_splash.img.extracted/4000.BMP
[] No padding added. Check file size.
[] Encoding: ../_splash.img.extracted/4000.BMP.nb
[] Image dimensions: 1080x1920
[] Adding 16384 bytes padding using pattern [0xff]
[] Done!

cd ../_splash.img.extracted
mv 4000.BMP splash.img
sha256sum splash.img
f8d76d18396a18051392fde3aa0e329338138068a2a354be3f488698c2f1c307  splash.img

binwalk splash.img

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             PC bitmap, Windows 3.x format,, 1080 x 1920 x 24
```
