#!/bin/bash

# credits: http://bobcopeland.com/blog/2012/10/goto-in-bash/
function jumpto
{
    label=$1
    cmd=$(sed -n "/:\s$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

echo "Hello to geexee Kerberos configuration."

start=${1:-"start"}

jumpto $start

: start:

read -n 1 -p "Do you want to setup Kerberos [y|n]?`echo $'\n> '`" answer
if [ "$answer" != "y" ]
then
	jumpto $start-services
fi

hostname=$HOSTNAME && placeholder_realm=${hostname#*.}
placeholder_realm=`echo $placeholder_realm | awk '{print toupper($1)}'`
read -p "Enter Realm: [$placeholder_realm]" realm 
if [ -z "$realm" ]
then
	realm=$placeholder_realm
fi

#placeholder_kdc_server=kdc.`echo $realm | awk '{print tolower($1)}'`
placeholder_kdc_server=$HOSTNAME
read -p "For Realm [$realm] enter KDC hostname [$placeholder_kdc_server]: " kdc_hostname 
if [ -z "$kdc_hostname" ]
then
	kdc_hostname=$placeholder_kdc_server
fi
echo "KDC hostaname=$kdc_hostname"

placeholder_kdc_admin_server=$kdc_hostname
read -p "For Realm [$realm] enter KDC admin server name [$placeholder_kdc_admin_server]: " kdc_admin_server
if [ -z "$kdc_admin_server" ]
then
	kdc_admin_server=$placeholder_kdc_admin_server
fi
echo "KDC admin server name=$kdc_admin_server"

read -p "Enter KDC DB password: " kdc_db_password
if [ -z "$kdc_db_password" ]
then
	echo "Need to specify a password. Exit."
	exit 1;
fi

read -p "Re-Enter KDC DB password: " kdc_db_password2
if [ -z "$kdc_db_password2" ]
then
	echo "Need to specify a password. Exit."
	exit 1;
fi

if [ "$kdc_db_password" != "$kdc_db_password2" ]
then
	echo "Passwords do not match. Exit."
	exit 1;
fi

COPY_FILES="/etc/krb5.conf /var/kerberos/krb5kdc/kadm5.acl /var/kerberos/krb5kdc/kdc.conf"
for f in $COPY_FILES; do sed -i 's/${REALM}/'"$realm"'/g' $f; done;
realmlo=`echo $realm | awk '{print tolower($1)}'`
sed -i 's/${REALMlo}/'"$realmlo"'/g' /etc/krb5.conf
sed -i 's/${KDC_KDC}/'"$kdc_hostname"'/g' /etc/krb5.conf
sed -i 's/${KDC_ADMIN_SERVER}/'"$kdc_admin_server"'/g' /etc/krb5.conf

kdb5_util create -r $realm -s -P $kdc_db_password

jumpto $start-services

: start-services:

systemctl start krb5kdc.service
systemctl enable krb5kdc.service
systemctl start kadmin.service
systemctl enable kadmin.service

echo "Start Terminal"
bash
echo "Press Ctrl+C to stop instance."
sleep infinity

