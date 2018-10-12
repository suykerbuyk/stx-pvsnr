#!/bin/sh

set -e
partprobe
ls
[ -f /root/provisioning.done ] && rm -f /root/provisioning.done

[ $(mountpoint -q '/part1/var' &>/dev/null) ] \
	&& logexec 'umount /part1/var'
[ $(mountpoint -q '/part1'     &> /dev/null) ] \
	&& logexec 'umount /part1'

# Destroy Volume groups
for grp in "$(vgs --noheadings --all --unbuffered -o vg_name)"; do
	grp=${grp//[[:blank:]]/}
	if [ "${grp}x" != "x" ]; then
		echo "___${grp}___"
		vgchange -a n ${grp}
		vgremove -y ${grp}
	fi
done

# Destroy Raid file systems
if [ -d /dev/md/ ]; then
	for dev in $(find /dev/md*p? -type b); do
		wipefs -fa ${dev}
	done
fi
RAID_MEMBERS=''
for disk in $(blkid | grep 'linux_raid_member' | awk -F ':' '{print $1}'); do
	echo adding: $disk
	RAID_MEMBERS="${RAID_MEMBERS} ${disk}"
done
for raid in $(find /dev/ -type b -name "md*" | grep -v 'p'); do
	mdadm --stop ${raid}
done
for disk in ${RAID_MEMBERS}; do
	mdadm --zero-superblock ${disk}
done

for disk in $(blkid | grep sd | grep 'LABEL'  | awk -F ':' '{print $1}' ); do
	wipefs -fa ${disk}
	dd if=/dev/zero bs=1M count=1000 of=${disk}
done
for disk in $(ls /dev/sd* | grep -e '[0-9]$'); do
	wipefs -fa ${disk}
	dd if=/dev/zero bs=1M count=100 of=${disk}
done
cd /dev/
for disk in $( ls sd* | grep -e '[^0-9]$' ) ; do
	sz="$(cat /sys/class/block/${disk}/size)"
	echo "Size=$sz"
	if [[ $sz > 0 ]] ; then
		wipefs -fa ${disk}
		dd if=/dev/zero bs=1M count=100 of=${disk}
	fi
done
partprobe
