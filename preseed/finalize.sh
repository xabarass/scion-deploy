#!/bin/bash

function log() {
 echo $(tput setaf 6)$(tput bold)"$@"$(tput sgr0)
}

# Save current resolv.conf contents
cp -L /etc/resolv.conf /root/resolv.conf.bkp

REMOVE="accountsservice dbus dictionaries-common discover discover-data emacsen-common gir1.2-glib-2.0:amd64 installation-report language-pack-en language-pack-en-base language-pack-gnome-en language-pack-gnome-en-base language-selector-common laptop-detect libaccountsservice0:amd64 libatm1:amd64 libcap-ng0:amd64 libdiscover2 libgirepository-1.0-1:amd64 libglib2.0-data libpolkit-gobject-1-0:amd64 libxmuu1:amd64 linux-generic python3-gi python3-requests python3-urllib3 resolvconf shared-mime-info ssh-import-id tasksel tasksel-data tcpd ubuntu-minimal wamerican wbritish xauth xdg-user-dirs"

ADD="dmidecode ed freeipmi-tools gawk gdebi-core htop ifenslave hdparm iptables iptables-persistent lm-sensors lsof manpages manpages-dev mlocate mtr-tiny nano netfilter-persistent ntpdate open-iscsi open-vm-tools overlayroot plymouth-theme-ubuntu-text pollinate strace supervisor systemd-shim telnet time tmux tree ubuntu-cloudimage-keyring update-motd update-notifier-common vim-nox vlan acpid apt-transport-https build-essential cloud-guest-utils cloud-initramfs-copymods fancontrol  fonts-ubuntu-font-family-console grub-legacy-ec2"

log "Pruning packages"
apt purge $REMOVE
log "Done pruning packages"

# We likely removed resolvconf, so we have to fix the DNS config before
# we can install extra packages.
log "Fixing /etc/resolv.conf"
rm -f /etc/resolv.conf
cp  /root/resolv.conf.bkp /etc/resolv.conf
log "/etc/resolv.conf fixed, backup preserved in /root/resolv.conf.bkp"

log "Adding packages"
apt install --no-install-recommends $ADD
log "Done adding packages"

log "Cleaning up unneeded packages"
apt --purge autoremove
log "Done and done."
