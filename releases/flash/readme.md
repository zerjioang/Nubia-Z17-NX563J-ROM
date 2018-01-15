# Flash files extracted from Official releases

## Building update.zip

To build update.zip flashable file from ROM files, unpack ROM files and save proper files using next command:

```
zip -r -0 update.zip .
```
This will create a **update.zip** file with all files inside. If success, output of the command is:

```
  adding: META-INF/ (stored 0%)
  adding: META-INF/com/ (stored 0%)
  adding: META-INF/com/google/ (stored 0%)
  adding: META-INF/com/google/android/ (stored 0%)
  adding: META-INF/com/google/android/update-binary (stored 0%)
  adding: META-INF/com/google/android/updater-script (stored 0%)
  adding: firmware-update/ (stored 0%)
  adding: firmware-update/abl.elf (stored 0%)
  adding: firmware-update/BTFM.bin (stored 0%)
  adding: firmware-update/hyp.mbn (stored 0%)
  adding: firmware-update/adspso.bin (stored 0%)
  adding: firmware-update/xbl.elf (stored 0%)
  adding: firmware-update/keymaster.mbn (stored 0%)
  adding: firmware-update/NON-HLOS.bin (stored 0%)
  adding: firmware-update/cmnlib64.mbn (stored 0%)
  adding: firmware-update/pmic.elf (stored 0%)
  adding: firmware-update/rpm.mbn (stored 0%)
  adding: firmware-update/devcfg.mbn (stored 0%)
  adding: firmware-update/cmnlib.mbn (stored 0%)
  adding: firmware-update/tz.mbn (stored 0%)
```

## Flashable files

Next, a list of all ROM flashable files are shown:

```
├── firmware-update
│   ├── abl.elf
│   ├── adspso.bin
│   ├── BTFM.bin
│   ├── cmnlib64.mbn
│   ├── cmnlib.mbn
│   ├── devcfg.mbn
│   ├── hyp.mbn
│   ├── keymaster.mbn
│   ├── NON-HLOS.bin
│   ├── pmic.elf
│   ├── rpm.mbn
│   ├── tz.mbn
│   └── xbl.elf
├── META-INF
│   └── com
│       └── google
│           └── android
│               ├── update-binary
│               └── updater-script
```
