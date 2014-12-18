#!/bin/ksh
# Administration command for WebSphere Application Server
# Version 2.2
#
# (C)2003 TeliaSonera
# Sami Kerola <sami.kerola@sonera.com>

# Installation paths.
WASINST="/opt/IBMWebAS"
#IBMHTTPD="/opt/IBMHTTPD"

# Log file
LOGFILE=$WASINST/logs/juxto.sh.log
# Time stampper.
stamp() {
    date "+%d.%m.%Y-%H:%M:%S" | awk '{printf "%s ", $0}' >> $LOGFILE
}

WSCP=`ps -ae|grep wscp`
if [ ! -z "$WSCP" ]; then
    stamp
    echo "wscp.sh already running, exiting." | tee -a $LOGFILE
    exit 1
fi

usage() {
echo 'Usage: juxto.sh [ACTION] [OPTION]
  Actions:
    -s       Start.
    -p       Stop.
    -f       Force stop.
    -r       Restart running ape[s].
    -t       Status.
    -T       Long status.
    -l       List application engines.
  Options:
    -a ape   Determine application engine, for example spcms.
             Without this option all engines will get action.
    -n node  Determine node aka host. Without this option local
             node will get action. By using "*" you specify all.'
}

# Handle actions.
restarter() {
    stamp
    echo "Restart "$NODE" $APE." | tee -a $LOGFILE
    if [ ! -z "$IBMHTTPD" ]; then
        $IBMHTTPD/bin/apachectl stop
    fi
    $WASINST/bin/wscp.sh -f $WASINST/bin/juxto.tcl restart "$NODE" $APE $SGROUP
    if [ ! -z "$IBMHTTPD" ]; then
        $IBMHTTPD/bin/apachectl start
    fi
}

stopper() {
    stamp
    echo "Stop "$NODE" $APE." | tee -a $LOGFILE
    if [ ! -z "$IBMHTTPD" ]; then
        $IBMHTTPD/stop
    fi
    $WASINST/bin/wscp.sh -f $WASINST/bin/juxto.tcl stop "$NODE" $APE $SGROUP
}

forcestoper() {
    stamp
    echo "Force stop "$NODE" $APE." | tee -a $LOGFILE
    if [ ! -z "$IBMHTTPD" ]; then
        $IBMHTTPD/stop
    fi
    $WASINST/bin/wscp.sh -f $WASINST/bin/juxto.tcl forcestop "$NODE" $APE $SGROUP
}

starter() {
    stamp
    echo "Start "$NODE" $APE." | tee -a $LOGFILE
    $WASINST/bin/wscp.sh -f $WASINST/bin/juxto.tcl start "$NODE" $APE $SGROUP
    if [ ! -z "$IBMHTTPD" ]; then
        $IBMHTTPD/start
    fi
}

tester() {
    stamp
    echo "Test "$NODE" $APE." | tee -a $LOGFILE
    $WASINST/bin/wscp.sh -f $WASINST/bin/juxto.tcl status "$NODE" $APE $SGROUP
}

longtester() {
    stamp
    echo "Long test "$NODE" $APE." | tee -a $LOGFILE
    $WASINST/bin/wscp.sh -f $WASINST/bin/juxto.tcl longstatus "$NODE" $APE $SGROUP |
    sed  's/} {/}\
    {/g'
}

lister() {
    stamp
    echo "List "$NODE" $APE." | tee -a $LOGFILE
    $WASINST/bin/wscp.sh -f $WASINST/bin/juxto.tcl list "$NODE" $APE $SGROUP
}

while getopts a:n:g:sfprtTl OPTION; do
    case $OPTION in
        s)
            START=1
            ;;
        p)
            STOP=1
            ;;
        f)
            FORCE=1
            ;;
        r)
            RESTART=1
            ;;
        t)
            TEST=1
            ;;
        T)
            LONGTEST=1
            ;;
        l)
            LIST=1
            ;;
        g)
            SGROUP=sg
            ;;
        a)
            APE=$OPTARG
            ;;
        n)
            NODE=$OPTARG
            ;;
        \?)
             usage
             exit 1
             ;;
    esac
done
shift `expr $OPTIND - 1`

if [ -z "$NODE" ]; then
    NODE=$HOSTNAME
fi

# Oookay what should be done?
if [ ! -z "$START" ] && [ ! -z "$STOP" ] || [ ! -z "$RESTART" ]; then
    restarter
elif [ ! -z "$STOP" ]; then
    stopper
elif [ ! -z "$FORCE" ]; then
    forcestoper
elif [ ! -z "$START" ]; then
    starter
elif [ ! -z "$TEST" ]; then
    tester
elif [ ! -z "$LONGTEST" ]; then
    longtester
elif [ ! -z "$LIST" ]; then
    lister
else
    usage
    exit 1
fi

exit 0
# EOF
