#!/bin/bash
############# u_boot ################ Arria 10 SoC - Boot from SD Card
home=$('pwd')
title=$(date "+%d-%m_%H_%M_%S_via_u-boot")
rm -rf $home/log
########## check compiler
compiler="./gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf"
if [ ! -d $compiler ]; then
	echo -e "\n\tнеобходимо установить компайлер, команды:" | tee -a $home/log
	echo -e "wget https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf.tar.xz"
	wget https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf.tar.xz
	echo -e "tar xf gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf.tar.xz"
	tar xf gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf.tar.xz
	echo -e "rm gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf.tar.xz"
fi
if [ -d "./gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf/bin" ]; then
	export PATH=`pwd`/gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf/bin:$PATH
else
	echo -e "\n\t\t\INSTALL COMPILER !!!\n" | tee -a $home/log
	exit
fi

a10_example_sdmmc=$('pwd')/a10_example.sdmmc

if [ -d $a10_example_sdmmc ]; then
	cd $a10_example_sdmmc
	TOP_FOLDER=`pwd`
#	echo -e "\t\tTOP_FOLDER=$TOP_FOLDER" | tee -a $home/log
else
	echo -e "\t$a10_example_sdmmc direcitory doesn't exist, \n\tdo build manually" | tee -a $home/log
	exit
fi

#echo -e "\n\t 0 текущая директория = $(pwd)"
a10_soc_devkit_ghrd_pro="a10_soc_devkit_ghrd_pro"
cd $TOP_FOLDER && cd $a10_soc_devkit_ghrd_pro
gsrd_dir=`pwd`
#echo -e "\n\t 1 текущая директория = $(pwd)"

if [ ! -d "../../u-boot-socfpga" ]; then
	echo "\tнеобходимо установить u-boot toolchan, команды:" | tee -a $home/log
	cd ../../
	echo -e "\tgit clone https://github.com/altera-opensource/u-boot-socfpga"
	git clone https://github.com/altera-opensource/u-boot-socfpga
	echo "cd u-boot-socfpga"
	cd u-boot-socfpga
	echo -e "\n\tтекущая директория = $(pwd)"
echo -e "u-boot версия = $(git branch)"
#	echo "текущая директория = $(pwd)"
	sleep 5
fi

cd $TOP_FOLDER/$a10_soc_devkit_ghrd_pro
rm -rf software/bootloader && mkdir -p software/bootloader && cd software/bootloader
#echo -e "\n\t2 текущая директория = $(pwd)"
cp ../../../../u-boot-socfpga . -r
cd u-boot-socfpga
echo -e "\n\t\tU-BOOT git версия = $(git branch)\n" | tee -a $home/log
#hps_isw_handoff="hps_isw_handoff"
#output_files="output_files"

#if [ ! -f "../../../hps_isw_handoff/hps.xml" ]; then
#	hps_isw_handoff=$(find $TOP_FOLDER/$a10_soc_devkit_ghrd_pro -maxdepth 1 -name ".*hps_isw_handoff" | sort | tail -1)
#	cp -r $hps_isw_handoff ../../../hps_isw_handoff
#else
#	hps_isw_handoff="$TOP_FOLDER/$a10_soc_devkit_ghrd_pro/hps_isw_handoff/hps.xml"
#fi
#if [ ! -d "../../../output_files" ]; then
#	output_files=$(find $TOP_FOLDER/$a10_soc_devkit_ghrd_pro -maxdepth 1 -name ".*output_files" | sort | tail -1)
#	cp -r $output_files ../../../output_files
#else
#	output_files="$TOP_FOLDER/$a10_soc_devkit_ghrd_pro/output_files"
#fi
#echo -e "\n\tu-boot будет использовать сборку из :\n$hps_isw_handoff \n$output_files"| tee -a $home/log
#echo -e "current dir $(pwd)"

#file ./arch/arm/mach-socfpga/qts-filter-a10.sh
#file ../../../../../hps_isw_handoff/hps.xml
#file arch/arm/dts/socfpga_arria10_socdk_sdmmc_handoff.h

hps_isw_handoff_dir=$(find $gsrd_dir -maxdepth 1 -type d -name hps_isw_handoff)
if [ -d $hps_isw_handoff_dir ]; then
	#echo -e "hps_isw_handoff_dir = $hps_isw_handoff_dir"
	./arch/arm/mach-socfpga/qts-filter-a10.sh $hps_isw_handoff_dir/hps.xml	./arch/arm/dts/socfpga_arria10_socdk_sdmmc_handoff.h
	#./arch/arm/mach-socfpga/qts-filter-a10.sh \
	#../../../../../hps_isw_handoff/hps.xml \
	#arch/arm/dts/socfpga_arria10_socdk_sdmmc_handoff.h
	re_recorded=$(date -r ./arch/arm/dts/socfpga_arria10_socdk_sdmmc_handoff.h  +"%m-%d %H:%M:%S")
	echo -e "Проверка\n\tfile $(file arch/arm/dts/socfpga_arria10_socdk_sdmmc_handoff.h) re-recorded at $re_recorded" | tee -a $home/log
	#echo -e "File socfpga_arria10_socdk_sdmmc_handoff.h re-recorded at $re_recorded"  | tee -a $home/log
else
	echo -e "error hps_isw_handoff not found in path $gsrd_dir"modified
	exit
fi

sleep 5
clear
export CROSS_COMPILE=arm-none-linux-gnueabihf-
#echo -e "т\n\t\tтекущая директория = \n$(pwd)"
#echo -e "\n\t\t\t U-BOOT конфигурация, лог пишем в u-boot.log"
#sleep 3
################### u-boot configure
echo "" > $home/u-boot.log
make socfpga_arria10_defconfig | tee $home/u-boot.log
#make socfpga_arria10_defconfig  > ../../../../../u-boot.log 2>&1
#cicle=0
################### u-boot compile
sleep 3
#make -j ${nproc} | tee ../../../../../u-boot.log
make -j ${nproc}  > $home/u-boot.log 2>&1 &
while [ $(($(wc -l $home/u-boot.log | cut -d " " -f 1)*100/871)) -lt 100 ]; do
	clear
	echo -e "\n\t\t\tU-BOOT сборка, лог пишем в u-boot.log"
	echo -e "\t\t\tготово $(($(wc -l $home/u-boot.log | cut -d " " -f 1)*100/871))%"
	sleep .5
done
clear
#rm -rf ghrd_10as066n2.core.rbf
#ln -s ../../../output_files/ghrd_10as066n2.core.rbf .
#rm -rf ghrd_10as066n2.periph.rbf
#ln -s ../../../output_files/ghrd_10as066n2.periph.rbf .
if [[ -f $gsrd_dir/output_files/ghrd_10as066n2.core.rbf  && -f $gsrd_dir/output_files/ghrd_10as066n2.periph.rbf ]]; then
	ln -s $gsrd_dir/output_files/ghrd_10as066n2.core.rbf .
	ln -s $gsrd_dir/output_files/ghrd_10as066n2.periph.rbf .
else
	echo -e "error : files ghrd_10as066n2.core.rbf or ghrd_10as066n2.periph.rbf not found in path $gsrd_dir"
	exit
fi

tools/mkimage -E -f board/altera/arria10-socdk/fit_spl_fpga.its fit_spl_fpga.itb

build=false
if [[ -f ./fit_spl_fpga.itb && -f ./u-boot.img ]]; then
	build=true
	echo -e "\n\n\t\t\tУСПЕШНО !!!\n"  | tee -a $home/log
	u_boot_img=$(find $(pwd) -maxdepth 1 -type f -name "u-boot.img")
	u_boot_spl=$(find $(pwd) -maxdepth 2 -type f -name "u-boot-splx4.sfp")
	#echo "u_boot_img = $u_boot_img u_boot_spl = $u_boot_spl" 
	echo -e "u-boot использовал файлы из"
	#realpath ../../../../../hps_isw_handoff
	#date -r $(realpath ghrd_10as066n2.core.rbf)  +"%m-%d %H:%M:%S"
	echo -e "\t"$(realpath ghrd_10as066n2.core.rbf) $(date -r $(realpath ghrd_10as066n2.core.rbf)  +"%m-%d %H:%M:%S")
	echo -e	"\t"$(realpath ghrd_10as066n2.periph.rbf) $(date -r $(realpath ghrd_10as066n2.periph.rbf)  +"%m-%d %H:%M:%S")
	echo -e	"\t"$(realpath $hps_isw_handoff_dir/hps.xml) $(date -r $(realpath $hps_isw_handoff_dir/hps.xml)  +"%m-%d %H:%M:%S")

#	echo -e "\n\t\tu-boot использовал файлы из \n$hps_isw_handoff \n$output_files"  | tee -a $home/log
	echo -e "Проверка \n\t$(file ./fit_spl_fpga.itb)\t"$(date -r ./fit_spl_fpga.itb  +"%m-%d %H:%M:%S") | tee -a $home/log
else
	echo -e "\n\n\t\t\tУВЫ...\n" | tee -a $home/log
fi
if $build; then
	echo -e "\n\t\t\tmake image for SD card"  | tee -a $home/log
	u_boot_dir=$`pwd`
#	echo -e "\n\tтекущая директория = $(pwd)"
#	TOP_FOLDER=/media/ignat/sda-7/rocket_boards_a10/a10_example.sdmmc
#	текущая директория =
#	/media/ignat/sda-7/rocket_boards_a10/a10_example.sdmmc/a10_soc_devkit_ghrd_pro/software/bootloader/u-boot-socfpga
	if [ ! -d $home/sd_card_images ]; then
		mkdir $home/sd_card_images
	fi
	tar_root=$(find $home/core_and_root -maxdepth 1 -type f -name "*rootfs.tar.gz")
	linux_kernel=$(find $home/core_and_root -maxdepth 1 -type f -name "zImage*.bin")
	file_dtb=$(find $home/core_and_root -maxdepth 1 -type f -name "*.dtb")
	if [[ ! -f $tar_root || ! -f $linux_kernel || ! -f $file_dtb ]]; then
		echo -e "\n\terror : some files <root.tar.gz> or <zImage.bin> or <.dtb> not found in path $home/core_and_root !!!"
		echo -e "\t\t\ttar_root $tar_root"
		echo -e "\t\t\tlinux_kernel $linux_kernel"
		echo -e "\t\t\tfile_dtb $file_dtb"
		exit
	fi
	cd $home/sd_card_images
	title_sd=$title
	title_sd+="_sd_card"
	rm -rf $title_sd && mkdir $title_sd && cd $title_sd
	path_sd_card=$(pwd)
	mkdir sdfs &&  cd sdfs
	#cp ~/mac_styhead_sda-7/images_arria10/zImage .
	#cp $linux_kernel .
	#cp ~/mac_styhead_sda-7/images_arria10/socfpga_arria10_socdk_sdmmc-arria10.dtb .
	#cp $(find $home/core_and_root -maxdepth 1 -type f -name "zImage*.bin") .
	#cp $(find $u_boot_dir -maxdepth 1 -type f -name "fit_spl_fpga.itb") .
	#cp $(fibd $u_boot_dir -maxdepth 1 -type f -name "u-boot.img") .
	cp $linux_kernel $(pwd)
	cp $file_dtb $(pwd)
	#u_boot_img=$u_boot_dir
	#u_boot_img+='/u-boot.img'
	cp $u_boot_img $(pwd)
	mkdir extlinux
	echo "LABEL Arria10 SOCDK SDMMC" > extlinux/extlinux.conf
	echo "    KERNEL ../$(basename $linux_kernel)" >> extlinux/extlinux.conf
	echo "    FDT ../$(basename $file_dtb)" >> extlinux/extlinux.conf
	echo "    APPEND root=/dev/mmcblk0p2 rw rootwait earlyprintk console=ttyS0,115200n8" >> extlinux/extlinux.conf
	cd ..
	mkdir rootfs && cd rootfs
	tar xf $tar_root
	rm -rf lib/modules/*
	cd $path_sd_card
	cp $u_boot_spl $(pwd)

	########################### make img
	cd $path_sd_card
	sudo python3 $home/make_sdimage_p3.py -f \
	-P $u_boot_spl,num=3,format=raw,size=10M,type=A2  \
	-P sdfs/*,num=1,format=fat32,size=32M \
	-P rootfs/*,num=2,format=ext3,size=132M \
	-s 600M \
	-n sdcard_a10.img
fi
if [[ -n $(file sdcard_a10.img | grep -c "partition 1") && \
	-n $(file sdcard_a10.img | grep -c "partition 2") && \
	-n $(file sdcard_a10.img | grep -c "partition 3") ]]; then
	echo -e "\n\t\t\tPath to sd_card image: \n\t$path_sd_card/sdcard_a10.img\n"
fi
