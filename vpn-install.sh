#! /bin/bash

########################################
# Checking for a username and password #
########################################

if [ -z $1 ]; then
	echo "[ERROR] Имя пользователя не задано"
	exit 1
else
	echo "[--] Проверяем имя пользователя"
fi

if [ -z $2 ]; then
	echo "[ERROR] Пароль не задан"
	exit 1
else
	echo "[--] Проверяем пароль"
fi

###########################
# Create user credentials #
###########################

cat > /etc/openvpn/client/cred <<EOF
$1
$2
EOF

#########################
# Create openvpn config #
#########################

cat /home/*/Загрузки/*.ovpn > /etc/openvpn/client/user.conf

##############################
# Create vpn systemd service #
##############################
cat > /etc/systemd/system/bazon-vpn.service <<EOF
[Unit]
Description=Bazon VPN service
After=network.target
[Service]
Type=simple
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/client/user.conf --auth-user-pass /etc/openvpn/client/cred
[Install]
WantedBy=multi-user.target
EOF

#################
# Start service #
#################

systemctl daemon-reload
systemctl enable bazon-vpn
systemctl start bazon-vpn
sleep 2

##################################
# Simple checking vpn connection #
##################################

systemctl status bazon-vpn > /tmp/bazon-vpn.log
VAR=$(cat /tmp/bazon-vpn.log | grep 'Initialization Sequence Completed' | awk '{print $8,$9,$10}')

if [ "$VAR" == "Initialization Sequence Completed" ]; then
	echo '[OK] Установка закончена'
	echo "Ваш IP адрес: $(curl -s 2ip.ru)"
	rm /tmp/bazon-vpn.log
else
	echo "[ERROR] Что-то пошло не так, просьба обратиться к администратору"
	exit 1
fi
