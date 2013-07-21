#!/bin/bash

# Export the given object from an SVG with inkscape and
# create an image with the correct size and density
# to be used in an Android app.

TARGET_ID=$1
SOURCE_SVG=$2

declare -A DENSITY_BY_NAME
DENSITY_BY_NAME[LDPI]=120
DENSITY_BY_NAME[MDPI]=160
DENSITY_BY_NAME[HDPI]=240
DENSITY_BY_NAME[XHDPI]=320

declare -A SIZES_BY_TYPE
SIZES_BY_TYPE[LDPI]="36,18,18,24,24"
SIZES_BY_TYPE[MDPI]="48,24,24,32,32"
SIZES_BY_TYPE[HDPI]="72,36,36,48,48"
SIZES_BY_TYPE[XHDPI]="96,48,48,48,48"

ASSET_PREFIX=("ic_launcher" "ic_menu" "ic_stat_notify" "ic_tab" "ic_dialog" )


identify -units PixelsPerInch -format "Source SVG: %w x %h %x x %y" ${SOURCE_SVG}


for SCREEN_DENSITY in "${!DENSITY_BY_NAME[@]}"; 
do

	TARGET_DENSITY=${DENSITY_BY_NAME[$SCREEN_DENSITY]};

  	echo ${SCREEN_DENSITY} --- ${DENSITY_BY_NAME[$SCREEN_DENSITY]};

	if [ ! -d "$SCREEN_DENSITY" ];
	then
		mkdir ${SCREEN_DENSITY}
	fi

  	OIFS=$IFS
  	IFS=','

	read -a ALL_SIZES_PX <<< "${SIZES_BY_TYPE[$SCREEN_DENSITY]}"

	PREFIX_INDEX=0
	
	for SIZE_PX in ${ALL_SIZES_PX[@]}
	do
        	EXPORT_IMG=$(mktemp --suffix .png)
		RESULT_IMG=${SCREEN_DENSITY}/${ASSET_PREFIX[$PREFIX_INDEX]}_${TARGET_ID}.png
	
		echo "Generating ${SCREEN_DENSITY} ${SIZE_PX} x ${SIZE_PX} to ${RESULT_IMG}"
		inkscape --export-id ${TARGET_ID} --export-height ${SIZE_PX} -e ${EXPORT_IMG} ${SOURCE_SVG} 
        	convert -units PixelsPerInch -resample ${TARGET_DENSITY} ${EXPORT_IMG} ${EXPORT_IMG}
        	convert -size ${SIZE_PX}x${SIZE_PX} -density ${TARGET_DENSITY} xc:none empty.png
		composite -gravity center ${EXPORT_IMG} -geometry ${SIZE_PX}x${SIZE_PX}  empty.png ${RESULT_IMG}

		rm ${EXPORT_IMG} empty.png
	
	let "PREFIX_INDEX++"
	done
	IFS=$OIFS
	done;

