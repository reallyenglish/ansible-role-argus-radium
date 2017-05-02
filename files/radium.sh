#!/bin/sh

# PROVIDE: radium
# REQUIRE: NETWORKING

. /etc/rc.subr

name="radium"
rcvar=radium_enable

load_rc_config $name

# Set defaults
: ${radium_enable="NO"}
: ${radium_flags="-f /usr/local/etc/radium.conf"}

required_files="${radium_config}"
command="/usr/local/bin/radium"
command_args="${radium_flags}"
start_cmd="radium_start"
pidfile="/var/run/radium.pid"

radium_start()
{
    if [ -z "$rc_fast" -a -n "$rc_pid" ]; then
        echo 1>&2 "${name} already running? (pid=$rc_pid)."
        return 1
    fi
    echo "Starting ${name}."
    /usr/sbin/daemon -p $pidfile ${command} ${radium_flags}
    _run_rc_postcmd
}

run_rc_command "$1"
