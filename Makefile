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

# TODO TEST upgrader thingy...

CONSTPARAM = -p 127.0.0.1:5900:5900 -v /home/backupuser/backup:/fs/backup:ro \
		-v /home/backupuser/megaconf:/home/linux-fan/.local/share/data \
		masysmalocal/megasync

build:
	docker build -t masysmalocal/megasync .

armhf_debian_8.tar.xz:
	docker pull armhf/debian:jessie
	docker save armhf/debian:jessie | xz -9 > armhf_debian_8.tar.xz

restore:
	unxz < armhf_debian_8.tar.xz | docker load

establish_run:
	docker run --restart=always --log-driver=syslog -d $(CONSTPARAM)

run_debug:
	docker run -it $(CONSTPARAM)

install_upgrader:
	dpkg -i mdvl-trivial-automatic-update*.deb
	systemctl enable mdvl-trivial-automatic-update.timer
	systemctl start mdvl-trivial-automatic-update.timer
