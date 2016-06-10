export USER="ben"

 
echo $(hostname -I | cut -d\  -f1) $(HOST_NAME) | tee -a /etc/hosts
rm -f /etc/hostname
touch /etc/hostname
bash -c 'echo "sautner.me" >> /etc/hostname'


apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y 
apt-get autoremove -y 
apt-get install ecryptfs-utils -y
 
keyctl link @u @s
adduser --disabled-password --gecos "" --force $USER 
keyctl unlink @u @s

adduser $USER sudo
bash -c 'echo "$USER ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)'


#mount my stuff
mkdir /data
bash -c 'echo "/dev/xvdf1 /data ext4 defaults,nofail 0 2" >> /etc/fstab'
mount -a
chown -R $USER /data

sudo usermod -d /data/home/ben $USER



apt-get -y install pass
#pass init $USER
#pass git init

#Setup Proxy
apt-get -y install squid
cp /etc/squid3/squid.conf /etc/squid3/squid.conf.original
chmod a-w /etc/squid3/squid.conf.original
cp -vf ./squid.conf /etc/squid3/squid.conf
service squid3 restart
 
 
apt-get -y install postfix
dpkg-reconfigure postfix
postconf -e 'home_mailbox = .mail'
postconf -e 'smtpd_sasl_local_domain ='
postconf -e 'smtpd_sasl_auth_enable = yes'
postconf -e 'smtpd_sasl_security_options = noanonymous'
postconf -e 'broken_sasl_auth_clients = yes'
postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
postconf -e 'inet_interfaces = all'

cp -v ./smtpd.conf /etc/postfix/sasl/smtpd.conf

postconf -e 'smtp_tls_security_level = may'
postconf -e 'smtpd_tls_security_level = may'
postconf -e 'smtpd_tls_auth_only = no'
postconf -e 'smtp_tls_note_starttls_offer = yes'
postconf -e 'smtpd_tls_key_file = /data/.certs/smtpd.key'
postconf -e 'smtpd_tls_cert_file = /data/.certs/smtpd.crt'
postconf -e 'smtpd_tls_CAfile = /etc/ssl/certs/cacert.pem'
postconf -e 'smtpd_tls_loglevel = 1'
postconf -e 'smtpd_tls_received_header = yes'
postconf -e 'smtpd_tls_session_cache_timeout = 3600s'
postconf -e 'tls_random_source = dev:/dev/urandom'
postconf -e 'myhostname = sautner.me' 

sudo cp /data/.certs/cacert.pem /etc/ssl/certs/
sudo cp /data/.certs/cakey.pem /etc/ssl/private/

sudo apt-get -y install libsasl2-2 sasl2-bin libsasl2-modules

cp -fv ./saslauthd /etc/default/saslauthd

sudo dpkg-statoverride --force --update --add root sasl 755 /etc/default/saslauthd
sudo ln -s /etc/default/saslauthd /etc/saslauthd

sudo apt-get -y install mailutils
sudo adduser ben mail
sudo touch /var/mail/ben
sudo chmod ug+rw /var/mail/ben
 
sudo apt-get -y install dovecot-imapd dovecot-pop3d
reboot






