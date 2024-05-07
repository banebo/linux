#!/bin/bash

clear
echo -e "\nPost-Install Script\n"


RED='\e[1;31m'
YELLOW='\e[1;33m'
GREEN='\033[1;32m'
BLUE='\e[1;34m'
CLS='\e[0m'
OK="["$GREEN"+"$CLS"]"
NOK="["$RED"-"$CLS"]"
INFO="["$BLUE"*"$CLS"]"
QUESTION="["$YELLOW"?"$CLS"]"
TAB="\\r\\033[K"


msg_info(){
	echo -e $INFO $1
}

msg_ok(){
	echo -e $TAB $OK OK
}

msg_nok(){
	echo -e $TAB $NOK $1
}

chk_status(){
	if [ $? -le 0 ]; then msg_ok; else msg_nok $1; fi
}


if [ $UID -ne 0 ]; then
	msg_nok "Not root, exiting..."
	exit 1
fi


OSID=$(cat /etc/os-release | grep -E "^ID=" | cut -d "=" -f2)

# GENERAL SETTINGS
echo "umask 027" >> /etc/profile
echo "unset HISTFILE" >> /etc/profile
echo "alias ll='ls -l'" >> /etc/profile
echo "alias la='la -Al'" >> /etc/profile


# UPDATE /etc/resolv.conf
msg_info "Configuring DNS resolver"
cat <<EOF >/etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
chk_status "Failed to edit the DNS: /etc/resolv.conf"

do_ssh(){
	msg_info "Installing OpenSSH..."
	case $OSID in
		debian)
			apt install openssh-server -y 1> /dev/null
			systemctl enable sshd
		;;
		alpine)
			apk add openssh
			rc-update add sshd
		;;
	esac

	msg_info "Configuring the SSH"
	if ! [ -d /root/.ssh ]; then
		mkdir /root/.ssh
	fi
	if ! [ -f /etc/ssh/sshd_config ]; then
		msg_nok "Could not find the file: /etc/ssh/sshd_config, skipping"
	else
		cat <<EOF >/etc/ssh/sshd_config
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

#Include /etc/ssh/sshd_config.d/*.conf

Protocol 2
MACs hmac-sha1,hmac-sha2-256,hmac-sha2-512

Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
LogLevel INFO

# Authentication:

LoginGraceTime 15
#PermitRootLogin prohibit-password
PermitRootLogin yes
#StrictModes yes
MaxAuthTries 3  # min 2
MaxSessions 3

PubkeyAuthentication yes
PubkeyAcceptedKeyTypes ssh-ed25519

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
AuthorizedKeysFile     .ssh/authorized_keys

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no
PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
KbdInteractiveAuthentication no

# Kerberos options
KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the KbdInteractiveAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via KbdInteractiveAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and KbdInteractiveAuthentication to 'no'.
UsePAM yes

#AllowAgentForwarding yes
AllowTcpForwarding no
#GatewayPorts no
X11Forwarding no
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no
#PrintLastLog yes
#TCPKeepAlive yes
PermitUserEnvironment no
#Compression delayed
# The server will terminate the client (which has already disconnected) after ClientAliveInterval * ClientAliveCountMax seconds
ClientAliveInterval 60
ClientAliveCountMax 5
#UseDNS no
#PidFile /run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale environment variables
#AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem       sftp    /usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#       X11Forwarding no
#       AllowTcpForwarding no
#       PermitTTY no
#       ForceCommand cvs server
EOF
		chk_status "Failed to edit the sshd config: /etc/ssh/sshd_config"
	fi

	# SETUP THE SSH ROOT PUBLIC KEY TO THE /root/.ssh/authorized_keys
	echo -e "$QUESTION Enter SSH public key: "
	read ssh_public
	echo $ssh_public > /root/.ssh/authorized_keys
	unset ssh_public
	chk_status "Failed to add the public key to the authorized_key"
}


# EDIT THE PACKAGE SOURCES
case $OSID in
	debian)
		msg_info "Updating /etc/apt/sources.list"
		cat <<EOF > /etc/apt/sources.list
deb https://deb.debian.org/debian bookworm main contrib
deb https://deb.debian.org/debian bookworm-updates main contrib

# Proxmox VE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

# security updates
deb https://security.debian.org/debian-security bookworm-security main contrib
EOF

		chk_status "Failed to edit the apt sources list: /etc/apt/sources.list"

		echo -e "$QUESTION Would you like to disable the pve-enterprise from the source? [y/n]:"
		read $choice
		if [[ $choice =~ ['y|Y'] ]]; then 
			msg_info "Editing the /etc/apt/sources.list.d/pve-enterprise.list"
			cat <<EOF > /etc/apt/sources.list.d/pve-enterprise.list
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
EOF
			chk_status "Failed to write to /etc/apt/sources.list.d/pve-enterprise.list"
			msg_info "Editing the /etc/apt/sources.list.d/pve-install-repo.list"
			cat <<EOF >/etc/apt/sources.list.d/ceph.list
deb http://download.proxmox.com/debian/ceph-quincy bookworm no-subscription
EOF
		chk_status "Failed to write to /etc/apt/sources.list.d/pve-install-repo.list"
		fi
	;;
	msg_info "Updating repositories..."
	apt update
	chk_status "Failed to update repositories"
esac
