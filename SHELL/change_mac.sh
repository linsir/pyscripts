#!/bin/bash
#author:vi5i0n
#date:2013-6-25
#the script can change the eth's mac address

#setting
eth=eth0

sudo ifconfig $eth down
echo "$eth is downing now!"
sleep 3
if [ $1 ];
then
	sudo macchanger -m $1 $eth
else
		sudo macchanger -r $eth
fi
sleep 2
sudo ifconfig $eth up
ifconfig $eth
exit 0


