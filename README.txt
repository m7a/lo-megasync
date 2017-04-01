----------------------------------------------------------------------[ Meta ]--

name		megasync_docker_arm
section		37
description	Running Megasync on amhf using Docker
tags		blog docker arm megasync
encoding	utf8
compliance	public
lang		en
creation	2017/04/02 00:33:14
version		1.0.0.0
copyright	Copyright (c) 2017 Ma_Sys.ma.
		For furhter info send an e-mail to Ma_Sys.ma@web.de.

-------------------------------------------------------------[ What is this? ]--

Using the image presented here, you can synchronize files with
Mega(http://mega.co.nz) using a Docker container on an ARM device.
Modifying the `Dockerfile` to build on top of `debian:jessie` instead of
`armhf/debian:jessie` yields an image suitable for running on an AMD64
device.

-----------------------------------------------------------[ Getting Started ]--

The image `masysmalocal/megasync` may be built locally using `make build`.
A Docker Hub automated build is not available due to ``exec format error''
if one attempts to automatically build this on Docker Hub.

You can run it as follows:

	docker run --restart=always -d -p 127.0.0.1:5900:5900 \
				-v ...:/fs/backup \
				-v ...:/home/linux-fan/.local/share/data \
				masysmalocal/megasync

Volumes are as follows:

`/fs/backup`
   Map the directory to be synced to this node.
`/home/linux-fan/.local/share/data`
   Map a directory to contain the Megasync configuration to this one.

In order to graphically interact with the client, connect via VNC like this:

	vncviewer localhost:0

--------------------------------------------------------[ About the Upgrader ]--

An experimental package called `mdvl-trival-automatic-update` is supplied as
part of this repository. It is installed inside the container as to keep a
24/7-running container up to date automatically. This script extends
`unattended-upgrades` by a means of automatically chosing between multiple
mirror hosts. By default, it checks for `192.168.1.16` to be online and if
that is not the case, it uses `ftp.de.debian.org` instead. This way, you can
run your own local mirror to upgrade your server on a best-effort basis: If the
upgrade happens while your local mirror is online, it will chose the local
mirror. If the upgrade happens while the local mirror is not reachable, the
process will take the upgrade from the internet.

If you wonder about supplying a `.deb` package as the ``source'' code -- there
is nothing more to it than the files contained so there is no need to provide
a ``separate'' source code. If you want to rebuild the `.deb`, extract it's
contents and use `dpkg-deb` or
MDPC(https://lists.debian.org/debian-user/2013/08/msg00042.html). If you
use MDPC, the package belongs to the ``raw'' category and the files should
be in a directory called after the package name.
