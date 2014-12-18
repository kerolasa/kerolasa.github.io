# Administration command for WebSphere Application Server
# Version 1.2
# Try this: wscp.sh -f juxto.tcl
#
# (C)2003 TeliaSonera
# Sami Kerola <sami.kerola@sonera.com>

if { $argc < 1 || $argc > 4 } {
    puts "Usage: juxto.tcl \[start|stop|restart|status|list\] \[node\] \[ape\] \[as|sg\]"
    exit 1
}

set action [lindex $argv 0]
set node [lindex $argv 1]
set ape [lindex $argv 2]
set object [lindex $argv 3]
# This idea wont work, wscp.sh cant handle environment variables.
#if { [string length $node] == 0 } {
#    set node $::env(HOSTNAME)
#}
set apes ""

case $object in {
    sg {
        set object "ServiceGroup"
    } default {
        set object "ApplicationServer"
    }
}

proc GetApes {node ape argc} {
    global apes
    set a [ApplicationServer list]
    foreach i $a {
        if { $argc == 3 } {
            if {[string match /Node:$node/ApplicationServer:$ape/ $i]} {
                append apes "{$i} "
            }
        } else {
            if {[string match /Node:$node/ApplicationServer:* $i]} {
                append apes "{$i} "
            }
        }
    }
}

proc statusToString {{status -1}} {
    global errorCode
    if { $status == -1 && $errorCode != "NONE" } {
        set status $errorCode
    }
    java::call com.ibm.ejs.sm.ejscp.WscpStatus statusToString $status
}

proc StartApes {} {
    global apes
    foreach i $apes {
        ApplicationServer start $i
        statusToString
    }
}

proc StopApes {} {
    global apes
    foreach i $apes {
        ApplicationServer stop $i
        statusToString
    }
}

proc ForceStopApes {} {
    global apes
    foreach i $apes {
        ApplicationServer stop $i -force
        statusToString
    }
}

proc RestartApes {} {
    global apes
    foreach i $apes {
        set x [ApplicationServer show $i -attribute CurrentState]
        set cstate [lindex [lindex $x 0] 1]
        if { $cstate == "Running" } {
            ApplicationServer stop $i
            statusToString
            after 15000
            ApplicationServer start $i
            statusToString
        }
    }
}

proc StatApes {} {
    global apes
    foreach i $apes {
        puts "[ApplicationServer show $i -attribute {FullName CurrentState}]"
        statusToString
    }
}

proc LongStatus {} {
    global apes
    foreach i $apes {
        puts [format "%s\n" [ApplicationServer show $i -attribute {FullName CurrentState DesiredState CommandLineArgs MaxStartupAttempts ProcessId ProcessPriorityActive StderrActive StdoutActive UmaskActive DebugEnabledActive ThreadPoolSize}]]
        statusToString
    }
}

proc ListApes {} {
    global apes
    foreach i $apes {
        puts "$i"
    }
}

GetApes $node $ape $argc

case $action in {
    start {
        StartApes
    } stop {
        StopApes
    } forcestop {
        ForceStopApes
    } restart {
        RestartApes
    } status {
        StatApes
    } longstatus {
	LongStatus
    } list {
        ListApes
    } default {
        puts "Usage: juxto.tcl \[start|stop|forcestop|restart|status|longstatus|list\] \[node\] \[ape\]"
    }
}

# EOF
