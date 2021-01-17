#!/bin/bash

for f in /etc/NetworkManager/system-conections/*; do
	sudo nmcli con modify "$f" ipv4.dns 1.1.1.1
done
