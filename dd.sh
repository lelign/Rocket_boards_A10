#!/bin/bash
#echo -e "\n"
echo -e "\n\t\t\tEnter full path to sd card image"
read path_sd_card_image
dev_exist=false
unset device
if [ -f $path_sd_card_image ]; then
 	device=$(lsblk --pairs | grep 'RM="1"' | grep -v 'SIZE="0B"' | cut -d " " -f 1 | head -1 | cut -d '"' -f 2)
	if [ -n $device ]; then
	        if [[ -n $(df | grep "/media/$(whoami)" | grep -o "/dev/$device") ]]; then
        	        echo -e "\n\t\t\t Needs umount!"
                	for dev in $(df | grep "/media/$(whoami)" | grep -o "/dev/$device"); do
                        	umount $dev
                	echo -e "\t\t\tUmounted $dev"
                	done
        	fi
		echo -e "\t\tПишем на /dev/$device? y/n "
		read do_it
		if [ $do_it == "y" ]; then
			sudo dd if=$path_sd_card_image of=/dev/$device status=progress
			sync
		else
			echo -e "...exit"
			sleep 3
			exit
		fi
	else
		echo -e "SD карта не найдена"
	fi
else
	echo -e "\t\t\Path\n $path_sd_card_image\n\t\t\tNOT EXIST!!!"
fi


exit

