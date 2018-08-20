#!/bin/sh
set -e
function usage() {
	if [ $# != 0 ] ; then
		echo "Error: $1"
	fi
	echo "Usage: $SCRIPT /dev/disk_device http://source/image/file.txz"
	exit 1
}

function showdone() {
	echo "Success: Imaging done"
	exit 0
}

if [ $# != 2 ] ; then
	usage "wrong number of parameters (expected 2)."
fi
SCRIPT="$(basename $0)"
DSK="${1}"
URL="${2}"
FILE=$(basename "${URL}")
EXT="${FILE##*.}"
MNT1="/part1"
MNT2="/part2"
DONE_MARKER=/root/provisioning.done

#exit if we are in a imaging done state
[ -e ${DONE_MARKER} ]  && [ -e ${MNT1}/${DONE_MARKER} ] && showdone

# exit if bad disk path/block device path given
[ ! -e "${DSK}" ] && usage "path to ${DSK} does not exists"

# exit if disk path is a regular file
[ -f "${DSK}"   ] && usage "${DSK} appears to be a regular file, not a disk"

# exit if the supplied image file source url is not a txz archive
[ "${EXT}x" != 'txzx' ] && usage "expected source file to end with extension '.txz', not '.$EXT'"

# echo SCRIPT: $SCRIPT
# echo URL:    $URL
# echo DSK:    $DSK
# echo FILE:   $FILE
# echo EXT:    $EXT
# echo MNT1:   $MNT1
# echo MNT2:   $MNT2

# Capture the complete command line to echo it later
CMD="curl -s ${URL} | tar -xJOf - | dd of=${DSK} bs=1M conv=fdatasync"
echo CMD: $CMD

# Create our mountpoints
[ -d ${MNT1} ] || mkdir -p ${MNT1} 
[ -d ${MNT2} ] || mkdir -p ${MNT2} 

# Make sure that things aren't already mounted.
mount -l | grep "${MNT2}" >/dev/null && umount "${MNT2}"
mount -l | grep "${MNT1}/var" >/dev/null && umount "${MNT1}/var"
mount -l | grep "${MNT1}" >/dev/null && umount "${MNT1}"

# Execute the imaging command
eval "$CMD" || exit 1

# Update kernel's partition tables
partprobe ${DSK}

# Remove the original single partition.
parted "${DSK}" rm 1 >/dev/null

# Recreate the first partion, but larger.
parted "${DSK}" mkpart primary ext4 1049kb 12900MB >/dev/null

# Create the second (/var) partition
parted "${DSK}" mkpart primary ext4 12901MB '100%' >/dev/null

# Set the "clean" flag on the resized root partition.
e2fsck -fp "${DSK}1" >/dev/null

# Stretch the root partion to fill the space available
resize2fs "${DSK}1"

# Create the file system for /var
mkfs.ext4 -q -L VAR /dev/sda2 >/dev/null

# Update the kernel's partition tables.
partprobe ${DSK} >/dev/null

# Mount the new root partition
mount ${DSK}1 ${MNT1}

# Mount what will be the /var partition
mount ${DSK}2 ${MNT2}

# Copy contents of original /var to new dedicated partion
rsync -ar ${MNT1}/var/ ${MNT2}/ --remove-source-files

# Clean up old var directory.
rm -rf ${MNT1}/var/*

# Capture the UUID's of the new partitions
UUID_P1=$(blkid ${DSK}1 | awk -F '"' '{print $4}')
UUID_P2=$(blkid ${DSK}2 | awk -F '"' '{print $4}')
#echo UUID_P1 = $UUID_P1
#echo UUID_P2 = $UUID_P2

# Build a new /etc/fstab for the new partitions
echo "UUID=${UUID_P1} / ext4 defaults 1 1"     >${MNT1}/etc/fstab
echo "UUID=${UUID_P2} /var ext4 defaults 1 1" >>${MNT1}/etc/fstab

# Remove the new /var partion mount
umount "${MNT2}"
rmdir "${MNT2}" 

# Mount the new /var where it should be on the new root partion
mount /dev/disk/by-uuid/${UUID_P2} ${MNT1}/var

# Set the name of the salt master
sed -i "s/^#* *master:.*/master: stx-prvsnr/g" ${MNT1}/etc/salt/minion

# Clean up old repos
rm -rf ${MNT1}/etc/yum.repos.d/*


cat >${MNT1}/etc/yum.repos.d/base.repo << EOF
[base]
name=base
baseurl=http://stx-prvsnr/vendor/centos/7.5.1804/
enabled=1
EOF

cat >${MNT1}/etc/yum.repos.d/centos.repo << EOF
[epel]
name=epel
baseurl=http://stx-prvsnr/vendor/centos/epel/
enabled=1
gpgcheck=0
EOF


cat >${MNT1}/etc/yum.repos.d/hermi << EOF
[hermi]
name=hermi
baseurl=http://stx-prvsnr/vendor/hermi/
enabled=1
gpgcheck=0
EOF

rpm --root ${MNT1}/ --import  http://stx-prvsnr/vendor/centos/7.5.1804/RPM-GPG-KEY-CentOS-7
yum clean all --installroot ${MNT1}/
yum update --installroot ${MNT1}/
yum install -y salt-minion  --installroot ${MNT1}/

# Copy preauthenticated salt minion keys
[ -d ${MNT1}/etc/salt/pki/minion/ ] || mkdir -p ${MNT1}/etc/salt/pki/minion/
rsync -ar /etc/salt/pki/minion/ ${MNT1}/etc/salt/pki/minion/ --delete-after
rsync -ar /root/.ssh/ ${MNT1}/root/.ssh/ --delete-after
rsync -ar /etc/ssh/ ${MNT1}/etc/ssh/ --delete-after

# if set, copy our minion ID to the new image.
[ -e /etc/salt/minion_id ] && rsync /etc/salt/minion_id ${MNT1}/etc/salt/minion_id
systemctl --root=${MNT1}/ enable salt-minion

# Set our imaging done flag(s) on both live root and imaged root.
date --rfc-3339=seconds >${DONE_MARKER}
cp ${DONE_MARKER} ${MNT1}/${DONE_MARKER}
