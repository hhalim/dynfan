#!/bin/bash

#set -x #DEBUG
#testTemp=(20 90) #TEST

#VARIABLES
declare -A LASTTEMP

MINTEMP=40
MAXTEMP=80
DELAY=10
DEGDELTA=3 #change temp if over or equal Xdeg change
LOCKDIR=/tmp/dynfan-lock

#Remove the lock directory
function cleanup {
    if rmdir $LOCKDIR; then
        echo "DynFan unlocked."
    else
        echo "Failed to remove lock directory '$LOCKDIR'"
        exit 1
    fi
}

function dynamicFan {
	while getopts ":l:u:d:h:" opt; do
		case ${opt} in
			l)
				MINTEMP=$OPTARG
				;;
			u)
				MAXTEMP=$OPTARG
				;;
			d)
				DELAY=$OPTARG
				;;
			h)
				DEGDELTA=$OPTARG
				;;
			\?)
				echo "Invalid option: $OPTARG" >&2
				exit 1
				;;
			:)
				echo "Invalid option: $OPTARG requires an argument" >&2
				exit 1
				;;
		esac
	done

	while sleep $DELAY; do
		index=0
		for x in $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader); do
		#for x in ${testTemp[@]}; do #DEBUG TEST
			#echo "index:$index"
			if [[ ${LASTTEMP[$index]} != $x ]] && [[ $x -ge $(( ${LASTTEMP[$index]} + DEGDELTA ))
					|| $x -le $(( ${LASTTEMP[$index]} - DEGDELTA )) ]]; then
				#echo "current: $x; LASTTEMP: ${LASTTEMP[$index]}; diff: $(( ${LASTTEMP[$index]} + DEGDELTA ))"

				if [ $x -le $MINTEMP ] || [ $x -ge $MAXTEMP ]; then
					#echo "current: $x; lte $MINTEMP or gte $MAXTEMP set AUTO"
					#set to auto temp
					DISPLAY=:0 nvidia-settings -a [gpu:$index]/GPUFanControlState=0 1> /dev/null
					LASTTEMP[$index]=$x
				else
					#echo "set fan: $x"
					#set fan only if temp changes
					DISPLAY=:0 nvidia-settings -a [gpu:$index]/GPUFanControlState=1 -a [fan:$index]/GPUTargetFanSpeed=$x 1> /dev/null
					LASTTEMP[$index]=$x
				fi

			fi
			#testTemp[$index]=$(( ${testTemp[$index]}-2 )) #TEST DEBUG

			index=$((index+1))
		done
	done
}

if mkdir $LOCKDIR; then
    #Ensure that if we "grabbed a lock", we release it
    #Works for SIGTERM and SIGINT(Ctrl-C)
    trap "cleanup" EXIT

    # Processing starts here
	dynamicFan
else
    echo "Could not create lock directory '$LOCKDIR'"
    exit 1
fi
