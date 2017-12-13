#!/bin/bash

#set -x #DEBUG

#VARIABLES
LASTTEMP=()

LOWERT=40  	#lower temp limit
UPPERT=80  	#upper temp limit
SDELAY=10  	#Sleep
DELTAT=3 	#delta temp to change fan speed
LOCKDIR=/tmp/dynfan-lock	#locking for only running one dynfan

#Remove the lock directory
function cleanup {
    if rmdir $LOCKDIR; then
        echo "DynFan unlocked."
    else
        echo "Failed to remove lock '$LOCKDIR'"
        exit 1
    fi
}

function dynamicFan {
	while getopts ":l:u:s:d:" opt; do
		case $opt in
			l)
				LOWERT=$OPTARG
				;;
			u)
				UPPERT=$OPTARG
				;;
			s)
				SDELAY=$OPTARG
				;;
			d)
				DELTAT=$OPTARG
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

	while sleep $SDELAY; do
		#echo "-------------------------------------" #DEBUG
		index=0
		for x in $(DISPLAY=:0 nvidia-settings -t -q=[gpu]/GPUCoreTemp); do
			#echo "$index -- Current: $x; LASTTEMP: ${LASTTEMP[$index]}" #DEBUG
			if [[ ${LASTTEMP[$index]} == $x ]]; then
				index=$((index+1))
				continue
			fi

			if  [ $x -le $LOWERT ] || [ $x -ge $UPPERT ]; then
				currentFanState=$(DISPLAY=:0 nvidia-settings -t -q [gpu:$index]/GPUFanControlState)
				if [[ $currentFanState != 0 ]]; then
					#echo "$index -- Temp: $x; lte $LOWERT or gte $UPPERT set to AUTO" #DEBUG
					#set to auto temp
					DISPLAY=:0 nvidia-settings -a [gpu:$index]/GPUFanControlState=0 1> /dev/null
					LASTTEMP[$index]=$x
				fi
			elif [ $x -le $(( ${LASTTEMP[$index]} - DELTAT )) ] || [ $x -ge $(( ${LASTTEMP[$index]} + DELTAT )) ]; then
				#echo "$index -- Temp: $x; Set fan: $x" #DEBUG
				# Manual fan speed between upper and lower temp limit
				DISPLAY=:0 nvidia-settings -a [gpu:$index]/GPUFanControlState=1 -a [fan:$index]/GPUTargetFanSpeed=$x 1> /dev/null
				LASTTEMP[$index]=$x
			fi

			index=$((index+1))
		done
	done
}

if mkdir $LOCKDIR; then
    #Ensure that if locked, release it
    #Works for SIGTERM and SIGINT(Ctrl-C)
    trap "cleanup" EXIT
	dynamicFan "$@"
else
    echo "Could not create lock '$LOCKDIR'"
    exit 1
fi
