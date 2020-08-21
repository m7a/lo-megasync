---
x-masysma-name: megasync
section: 32
title: Running Megasync on armhf using Docker
keywords: ["docker", "arm"]
lang: en-US
date: 2017/04/02 00:33:14
version: 1.1.2
x-masysma-copyright: |
  Copyright (c) 2017, 2019, 2020 Ma_Sys.ma.
  For furhter info send an e-mail to Ma_Sys.ma@web.de.
x-masysma-repository: https://www.github.com/m7a/lo-megasync
x-masysma-website: https://masysma.lima-city.de/32/megasync.xhtml
x-masysma-owned: 1
---
What is this?
=============

Using the image presented here, you can synchronize files with
[Mega](http://mega.co.nz) using a Docker container on an ARM device.

Getting Started
===============

Obtian the scripts from Github as follows:

	git clone https://github.com/m7a/lo-megasync.git

The image `armhf/masysmalocal/megasync` may then be built on an amd64 host
sytsem using `make build`.

You can run it as follows:

	docker run --restart=unless-stopped -d -p 127.0.0.1:5900:5900 \
				-v ...:/fs/backup \
				-v ...:/home/linux-fan/.local/share/data \
				masysmalocal/megasync

Volumes are as follows:

`/fs/backup`
:   Map the directory to be synced to this node.
`/home/linux-fan/.local/share/data`
:   Map a directory to contain the Megasync configuration to this one.

For successful read/write access from inside and outside the container, the
files from the shared volumes should belong to user and group with ID 1024. If
you want to use a different ID, change the `Dockerfile` accordingly and rebuild
the image.

In order to graphically interact with the client, connect via VNC like this:

	vncviewer localhost:0

About the Upgrader
==================

A binary version of `mdvl-trival-automatic-update` is supplied as
part of this repository. It is installed inside the container as to keep a
24/7-running container up to date automatically.
Check [trivial_automatic_update(32)](trivial_automatic_update.xhtml) for further
details including a link to the package's source code repository.

Newer Ideas
===========

 * Might want to switch to systemd to manage the different processes inside the
   container.
