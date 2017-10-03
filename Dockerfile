FROM local/c7-systemd
# FROM centos:7

#!! NTP
ARG ZONEINFO=Europe/Athens

ADD docker-files/geexee-setup-kdc.sh /usr/bin/geexee-setup-kdc.sh
#ADD docker-files/geexee-setup-static-ip.sh /usr/bin/geexee-setup-static-ip.sh

RUN \
    chmod +x /usr/bin/geexee-setup-kdc.sh && \
    chmod +x /usr/bin/geexee-setup-static-ip.sh

# add a timeout=300 in [main] section of /etc/yum.conf
#	this is due to my LAN problems
RUN awk '/\[main\]/{ start=1 } {if(start) ++start; if(start==3) print "timeout=300"} 1' /etc/yum.conf > /etc/yum.conf.tmp
RUN cp /etc/yum.conf.tmp /etc/yum.conf && rm /etc/yum.conf.tmp

#!! install networking essentials
RUN yum -y install initscripts && yum clean all
RUN yum -y install net-tools
RUN yum -y install iproute

#!! we need this to open TCP ports
#RUN yum -y install firewalld

#!! install ntp
RUN yum -y install ntp

RUN cp /usr/share/zoneinfo/$ZONEINFO /etc/localtime

#!! RUN ntpdate 0.rhel.pool.ntp.org
RUN systemctl enable ntpd.service

#!! Kerberos

#!! Install and configure KRB
RUN yum -y install krb5-server krb5-libs

COPY docker-files/etc_krb5.conf /etc/krb5.conf
COPY docker-files/var_kerberos_krb5kdc_kadm5.acl /var/kerberos/krb5kdc/kadm5.acl
COPY docker-files/var_kerberos_krb5kdc_kdc.conf /var/kerberos/krb5kdc/kdc.conf

EXPOSE 88:88
EXPOSE 749:749

CMD ["geexee-setup-kdc.sh"]
