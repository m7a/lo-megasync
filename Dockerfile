# Dockerfile and Supporting files to run megasync on armhf devices,
# Copyright (c) 2017, 2019, 2020 Ma_Sys.ma.
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

ARG MA_DEV_ARCH=
ARG MA_TARGET_ARCH=arm32v7/

FROM ${MA_DEV_ARCH}debian:buster AS qemustatic
ARG MA_DEBIAN_MIRROR=http://ftp.de.debian.org/debian
SHELL ["/bin/sh", "-ec"]
RUN \
	echo deb $MA_DEBIAN_MIRROR buster main > /etc/apt/sources.list; \
	echo deb $MA_DEBIAN_MIRROR buster-updates main \
						>> /etc/apt/sources.list; \
	echo deb http://security.debian.org/ buster/updates main \
						>> /etc/apt/sources.list; \
	apt-get update; \
	apt-get -y dist-upgrade; \
	apt-get -y install qemu-user-static

FROM ${MA_TARGET_ARCH}debian:buster
ARG MA_DEBIAN_MIRROR=http://ftp.de.debian.org/debian
# alt. Debian_10.0
ARG MA_TARGET_DEB=Raspbian_10.0
LABEL maintainer "Linux-Fan <Ma_Sys.ma@web.de>"
COPY --from=qemustatic /usr/bin/qemu-arm-static /usr/bin/qemu-arm-static
COPY megasync_ctrl.sh /usr/local/bin
COPY mdvl-trivial-automatic-update*.deb /var/tmp
SHELL ["/bin/sh", "-ec"]
RUN \
	echo deb $MA_DEBIAN_MIRROR buster main > /etc/apt/sources.list; \
	echo deb $MA_DEBIAN_MIRROR buster-updates main \
						>> /etc/apt/sources.list; \
	echo deb http://security.debian.org/ buster/updates main \
						>> /etc/apt/sources.list; \
	chmod +x /usr/local/bin/megasync_ctrl.sh; \
	useradd -u 1024 -m linux-fan; \
	mkdir -p /home/linux-fan/.vnc /home/linux-fan/.local/share/data; \
	echo \$vncStartup = \"exec /usr/bin/icewm\" > $HOME/.vncrc; \
	chown linux-fan:linux-fan -R /home/linux-fan; \
	mkdir -p /etc/X11/icewm; \
	printf "%s\n\n%s\n" "#!/bin/sh -e" "/usr/bin/megasync &" \
						> /etc/X11/icewm/startup; \
	chmod +x /etc/X11/icewm/startup; \
	apt-get update; \
	apt-get -y dist-upgrade; \
	apt-get install -y apt-transport-https tightvncserver icewm procps \
			rxvt-unicode-lite unattended-upgrades gnupg wget \
			xfonts-base; \
	echo deb https://mega.nz/linux/MEGAsync/${MA_TARGET_DEB}/ ./ > \
				/etc/apt/sources.list.d/megasync_tmp.list; \
	wget -O- https://mega.nz/linux/MEGAsync/${MA_TARGET_DEB}/Release.key | \
								apt-key add -; \
	apt-get update; \
	# Hack to prevent APT command from failing because the package attempts
	# to modify a kernel parameter.
	cp /bin/true /sbin/sysctl; \
	apt-get install -y megasync; \
	rm /etc/apt/sources.list.d/megasync_tmp.list; \
	# install auto-upgrade script.
	# rm would be pointless because its in the layers anyways
	dpkg -i /var/tmp/mdvl-trivial-automatic-update*.deb

EXPOSE 5900
HEALTHCHECK --interval=120s --timeout=20s --retries=3 \
				CMD exec /usr/local/bin/megasync_ctrl.sh -h
CMD ["/usr/local/bin/megasync_ctrl.sh", "-e"]
