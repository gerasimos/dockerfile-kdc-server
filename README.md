Instructions
============

* [Installing Kerberos on Redhat 7](https://gist.github.com/ashrithr/4767927948eca70845db)

## How to run

Open `run` and edit:

* `hostname`

```shell
$ ./run
```

## Post installation

First, you need to setup the Realm. For this, execute:

```shell
$ geexee-setup-kdc.sh
```


You need to add principles, e.g.:

```shell
[root@kdc ~]# kadmin.local
kadmin.local:  addprinc root/admin
kadmin.local:  addprinc user1
kadmin.local:  ktadd -k /var/kerberos/krb5kdc/kadm5.keytab kadmin/admin
kadmin.local:  ktadd -k /var/kerberos/krb5kdc/kadm5.keytab kadmin/changepw
kadmin.local:  exit
```

## Setup kerberos client

Hop onto the client server and add some host principals:

```shell
[root@client ~]# kadmin -p root/admin
kadmin:  addpinc --randkey host/client.example.com
kadmin:  ktadd host/kdc.example.com
```

## Static IP

[Calculate subnets](http://jodies.de/ipcalc?host=192.168.250.80&mask1=29&mask2=)

Modify values as required:

```shell
$ docker network create --subnet=172.18.0.0/16 mysubnet
```

and then append the following arguments to `run`:

* `--net=mysubnet`
* `--ip=172.18.0.22`



