#!/bin/bash
# Purpose - Script to add a sudo user to Linux system including passsword
# ------------------------------------------------------------------
# Am i Root user?
if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
	read -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p "$pass" "$username"
		usermod -aG sudo "$username"
		[ $? -eq 0 ] && echo "User $username has been added to system as sudoer!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system."
	exit 2
fi
