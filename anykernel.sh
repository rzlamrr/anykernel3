# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=ginkgo
device.name2=willow
device.name3=
device.name4=
device.name5=
supported.versions=8 - 11
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;


## AnyKernel install
dump_boot;


write_boot;
## end install
mount -o remount,rw /vendor;
STARGET="/vendor/etc/init/hw/init.target.rc"
FTARGET="/vendor/etc/init/hw/init.target.rc.silont"
if grep '/sys/touchpanel/double_tap' "${STARGET}" > /dev/null; then
    dtw=true
    ui_print " " " - Skipping DT2W patch..."
else
    ui_print " " " - Patching DT2W fix..."
    if [[ -e "${FTARGET}" ]]; then
        ftw=true
        rm "${FTARGET}"
        cp "${FTARGET}" "${STARGET}"
    else
        cp "${STARGET}" "${FTARGET}"
    fi
    sed -i 's/DT2W/&\n    chown system system \/sys\/touchpanel\/double_tap\n    chmod 0666 \/sys\/touchpanel\/double_tap\n    write \/sys\/touchpanel\/double_tap 1/g' "${STARGET}"
fi

## Make magisk module
if [[ "${dtw}" == "true" && "${ftw}" != "true" ]]; then
    :
else
    if [[ -d "/data/adb/modules/silont_fix" ]]; then
        ui_print " " " - Updating DT2W fix module..." " "
        rm -rf /data/adb/modules/silont_fix
    else
        ui_print " " " - Installing DT2W fix module..." " "
    fi
    mkdir -p /data/adb/modules/silont_fix
    cp -rf silont_fix/ /data/adb/modules/
fi
