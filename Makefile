# Dockerfile and Supporting files to run megasync on armhf devices,
# Copyright (c) 2017, 2020, 2022 Ma_Sys.ma.
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

CONSTPARAM = -p 127.0.0.1:5900:5900 -v /home/backupuser/backup:/fs/backup:ro \
		-v /home/backupuser/megaconf:/home/linux-fan/.local/share/data \
		armhf/masysmalocal/megasync

build:
	docker build -t armhf/masysmalocal/megasync .

build_amd64:
	docker build -f Dockerfile_amd64 -t masysmalocal/megasync .

build_ma:
	docker build -t armhf/masysmalocal/megasync \
		--build-arg MA_DEBIAN_MIRROR=http://192.168.1.16/debian .

build_ma_amd64:
	docker build -f Dockerfile_amd64 -t masysmalocal/megasync \
		--build-arg MA_DEBIAN_MIRROR=http://192.168.1.16/debian .

save:
	docker save armhf/masysmalocal/megasync | pv | \
				xz -9 -T 8 > armhf_masysmalocal_megasync.tar.xz

restore:
	pv armhf_masysmalocal_megasync.tar.xz | unxz | docker load 

establish_run:
	docker run --restart=unless-stopped --log-driver=syslog -d $(CONSTPARAM)

establish_run_amd64:
	docker run --restart=unless-stopped --name=ma-d-megasync \
		--log-driver=syslog -d -p 127.0.0.1:5900:5900 \
		-v /home/backupuser/backup:/fs/backup:ro \
		-v /home/backupuser/megaconf:/home/linux-fan/.local/share/data \
		masysmalocal/megasync

run_debug:
	docker run -it $(CONSTPARAM)

install_upgrader:
	dpkg -i mdvl-trivial-automatic-update*.deb
	systemctl enable mdvl-trivial-automatic-update.timer
	systemctl start mdvl-trivial-automatic-update.timer
