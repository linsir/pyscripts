#!bin/bash
#author:vi5i0n
#data:2013-06-24
#
read -p "pls input the brightness value(20-976):" value

if [ $value -lt 20 -o $value -gt 976   ];
	then
		echo "Error value!"
		exit 0
	else
        echo $value > /sys/class/backlight/intel_backlight/brightness
#		echo "Have changed!"
fi
exit 0

