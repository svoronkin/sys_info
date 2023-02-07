#!/bin/sh
# положить, дописать путь до скрипта в конец /etc/bashrc
#
#
#[ -r /etc/lsb-release ] && . /etc/lsb-release
#
#if [ -z "$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
#        # Fall back to using the very slow lsb_release utility
#        DISTRIB_DESCRIPTION=$(lsb_release -s -d)
#fi
#
figlet $(hostname)
printf "\n"

printf "Welcome to %s (%s).\n" "$DISTRIB_DESCRIPTION" "$(cat /etc/centos-release)"
printf "\n"

#System date
date=`date`

#System load
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))

#Root fs info
root_usage=`df -h / | awk '/\// {print $4}'|grep -v "^$"`
fsperm=$(mount | grep root | awk '{print $6}' | awk -F"," '{print $1}')

#Memory Usage
memory_usage=`free -m | awk '/Mem:/ { total=$2 } /buffers\/cache/ { used=$3 } END { printf("%3.1f%%", used/total*100)}'`
swap_usage=`free -m | awk '/Swap/ { printf("%3.1f%%", $3/$2*100) }'`

#Users
users=`users | wc -w`
USER=`whoami`

#Processes
processes=`ps aux | wc -l`

#Interfaces
INTERFACE=$(ip -4 ad | grep 'state UP' | awk -F ":" '!/^[0-9]*: ?lo/ {print $2}')

echo " System information as of: $date"
echo
printf " System Load:\t%s %s %s\tSystem Uptime:\t\t%s "days" %s "hours" %s "min" %s "sec"\n" $LOAD1, $LOAD5, $LOAD15 $upDays $upHours $upMins $upSecs
printf " Memory Usage:\t%s\t\t\tSwap Usage:\t\t%s\n" $memory_usage $swap_usage
printf " Usage On /:\t%s\t\t\tAccess Rights on /:\t%s\n" $root_usage $fsperm
printf " Local Users:\t%s\t\t\tWhoami:\t\t\t%s\n" $users $USER
printf " Processes:\t%s\t\t\t\n" $processes
printf " \n"
printf " Interface\tMAC Address\t\tIP Address\t\n"

for x in $INTERFACE
do
        MAC=$(ip ad show dev $x |grep link/ether |awk '{print $2}')
        IP=$(ip ad show dev $x |grep -v inet6 | grep inet|awk '{print $2}')
        printf  $x"\t\t"$MAC"\t"$IP"\t\n"

done
echo
df -hT
echo
echo

