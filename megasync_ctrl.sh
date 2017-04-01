#!/bin/bash -e
# Ma_Sys.ma Mega Sync Control Script 1.0.0.0, Copyright (c) 2017 Ma_Sys.ma.
# For further info send an e-mail to Ma_Sys.ma@web.de
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

# This is currently a ``bash'' script because otherwise `trap` does not work...

is_online=1
checkresult=
pid_megasync=tbd
pid_icewm=tbd
pid_vnc=tbd
pid_mywait=tbd

mamain() {
	case "$1" in
	(-e) maentrypoint;;
	(-h) mahealthcheck;;
	(-l) masublnx;;
	(*)  mahelpdefault;;
	esac
}

maentrypoint() {
	mahdr

	if [ -f /tmp/debug_halt ]; then
		mamsg "DEBUG HALT DETECTED -- $(cat "/tmp/debug_halt") --"
		exec tail -f /dev/null
	fi

	mamsg Switching to user linux-fan for user-specific actions...
	su -c "\"$0\" -l" linux-fan

	mamsg Entering online operation as user $(id -u)...
	trap mathdl INT QUIT TERM

	while [ "$is_online" = 1 ]; do
		mamsg "Attempting automatic upgrade..."
		fc=0
		while ! /usr/bin/ma_trivial_automatic_update; do
			fc=$(($fc + 1))
			if [ "$fc" -ge 30 ]; then
				mamsg Fail count exceeded, fail count = ${fc}. \
							Periodic updates halted.
				exit 1
			fi
			mamsg Fail count = ${fc}. Retrying after 30 sec...
			sleep 30
		done
		mamsg "Yield..."
		# 24 * 3600, IOW. ``once per day''
		sleep 86400 &
		pid_mywait=$!
		rc=0
		wait "$pid_mywait" || rc=$?
		mamsg "Yield finished w/ status ${rc}."
	done

	mamsg "Online status switched to 0. Terminated."
	exit 0
}

masublnx() {
	mamsg Configuring...
	[ ! -f /tmp/.X0-lock  ] || rm -f  /tmp/.X0-lock
	[ ! -e /tmp/.X11-unix ] || rm -rf /tmp/.X11-unix
	echo testwort | vncpasswd -f > "$HOME/.vnc/passwd"
	chmod 0600 "$HOME/.vnc/passwd"

	mamsg Starting VNC server...
	USER=linux-fan /usr/bin/vncserver -geometry 1024x768 :0
}

mawait() {
	while [ -e "/proc/$1" ]; do
		sleep 1
	done
}

mahdr() {
	head -n 3 "$0" | tail -n 2 | cut -c 3-
}

mamsg() {
	printf "[%s | %d] MA_MSG %s\n" "$(date "+%Y/%m/%d %H:%M:%S")" "$$" "$*"
}

mathdl() {
	mamsg "Received shutdown signal..."
	mafindproc
	macheckallproc || true
	mamsg "Process status before shutdown: $checkresult"
	for i in $pid_megasync $pid_ciewm $pid_vnc; do
		mamsg "Terminating ${i}..."
		kill -s TERM "$i" 2> /dev/null || true
		mamsg "Waiting for termination to take effect..."
		mawait "$i"
		mamsg "$i successfully terminated."
	done
	mafindproc
	macheckallproc || true
	mamsg "Process status after child process shutdown: ${checkresult}."
	is_online=0
	mamsg "Terminating yield process ${pid_mywait}..."
	kill -s TERM "$pid_mywait"
	mawait "$pid_mywait"
	mamsg "Container shutdown successful."
	exit 0
}

mahealthcheck() {
	mafindproc
	if macheckallproc; then
		echo "$checkresult"
		exit 0
	else
		echo "$checkresult"
		exit 1
	fi
}

mafindproc() {
	psl="$(COLUMNS=512 ps -A -o pid,args | sed 's/^ \+//g')"
	pid_megasync="$(echo "$psl" | grep -E 'megasync$' | cut -d" " -f1)"
	pid_icewm="$(echo "$psl"    | grep -E 'icewm$'    | cut -d" " -f1)"
	pid_vnc="$(echo "$psl"      | grep -F "Xtightvnc" | cut -d" " -f1)"
}

# $1: descr, $2 pid
macheckproc() {
	if [ -n "$2" ] && [ -e "/proc/$2" ]; then
		checkresult="$checkresult$1=$2 [ OK ] "
		return 0
	else
		checkresult="$checkresult$1=$2 [FAIL] "
		return 1
	fi
}

macheckallproc() {
	checkresult=
	r1=0
	macheckproc megasync "$pid_megasync" || r1=$?
	r2=0
	macheckproc icewm "$pid_icewm" || r2=$?
	r3=0
	macheckproc vnc "$pid_vnc" || r3=$?
	if [ "$r1" = 0 ] && [ "$r2" = 0 ] && [ "$r3" = 0 ]; then
		return 0
	else
		return 1
	fi
}

mahelpdefault() {
	mahdr
	echo "USAGE $0 -e|-h"
	exit 1
}

mamain "$@"
