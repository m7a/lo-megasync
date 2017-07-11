FROM armhf/debian:jessie
LABEL maintainer "Linux-Fan <Ma_Sys.ma@web.de>"

# Dockerfile and Supporting files to run megasync on armhf devices,
# Copyright (c) 2017 Ma_Sys.ma.
# For further info send an e-mail to Ma_Sys.ma@web.de.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

COPY megasync_ctrl.sh /usr/local/bin
COPY mdvl-trivial-automatic-update*.deb /var/tmp

ARG MA_DEBIAN_MIRROR=http://192.168.1.16/debian

RUN \
	echo deb $MA_DEBIAN_MIRROR jessie main > /etc/apt/sources.list && \
	echo deb $MA_DEBIAN_MIRROR jessie-updates main \
						>> /etc/apt/sources.list && \
	echo deb http://security.debian.org/ jessie/updates main \
						>> /etc/apt/sources.list && \
	chmod +x /usr/local/bin/megasync_ctrl.sh && \
	useradd -u 1024 -m linux-fan && \
	mkdir -p /home/linux-fan/.vnc /home/linux-fan/.local/share/data && \
	echo \$vncStartup = \"exec /usr/bin/icewm\" > $HOME/.vncrc && \
	chown linux-fan:linux-fan -R /home/linux-fan && \
	mkdir -p /etc/X11/icewm && \
	printf "%s\n\n%s\n" "#!/bin/sh -e" "/usr/bin/megasync &" \
						> /etc/X11/icewm/startup && \
	chmod +x /etc/X11/icewm/startup && \
	apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get install -y apt-transport-https tightvncserver icewm \
				rxvt-unicode-lite unattended-upgrades && \
	echo deb https://mega.nz/linux/MEGAsync/Raspbian_8.0/ ./ > \
				/etc/apt/sources.list.d/megasync_tmp.list && \
	apt-get update && \
	# Hack to prevent APT command from failing because the package attempts
	# to modify a kernel parameter.
	mv /sbin/sysctl /sbin/sysctl.bak && \
	cp /bin/true /sbin/sysctl && \
	# force to skip signature check once
	apt-get install --allow-unauthenticated -y megasync && \
	rm /etc/apt/sources.list.d/megasync_tmp.list && \
	# install auto-upgrade script.
	dpkg -i /var/tmp/mdvl-trivial-automatic-update*.deb && \
	rm /var/tmp/mdvl-trivial-automatic-update*.deb

EXPOSE 5900
HEALTHCHECK --interval=120s --timeout=20s --retries=3 \
				CMD exec /usr/local/bin/megasync_ctrl.sh -h

CMD [ "/usr/local/bin/megasync_ctrl.sh", "-e" ]
