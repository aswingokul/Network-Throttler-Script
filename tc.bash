#!/bin/bash
#
#  tc uses the following units when passed as a parameter.
#  kbps: Kilobytes per second
#  mbps: Megabytes per second
#  kbit: Kilobits per second
#  mbit: Megabits per second
#  bps: Bytes per second
#       Amounts of data can be specified in:
#       kb or k: Kilobytes
#       mb or m: Megabytes
#       mbit: Megabits
#       kbit: Kilobits
#  To get the byte figure from bits, divide the number by 8 bit
#
TC=/usr/sbin/tc
IF=br0		    # Interface
DNLD=50kbit          # DOWNLOAD Limit
UPLD=4mbit          # UPLOAD Limit
TIMER=30s
IP=$2     # Host IP
U32="$TC filter add dev $IF protocol ip parent 1:0 prio 1 u32"

start() {

    $TC qdisc del root dev $IF
    $TC qdisc add dev $IF root handle 1: htb default 30
    $TC class add dev $IF parent 1: classid 1:1 htb rate $DNLD
    $TC class add dev $IF parent 1: classid 1:2 htb rate $UPLD
    $U32 match ip dst $IP/32 flowid 1:1
    $U32 match ip src $IP/32 flowid 1:2

}

initial(){
    DNLD=2mbit
    UPLD=2mbit

    export DNLD UPLD
}

Speed_3G() {
 DNLD=1mbit
 UPLD=1mbit

 export DNLD UPLD
}

Speed_2G() {
 DNLD=100kbit
 UPLD=100kbit

 export DNLD UPLD
}

No_Network(){
DNLD=50kbit
UPLD=50kbit

export DNLD UPLD
}



#echo "DNLD val: $DNLD"


stop() {

    $TC qdisc del dev $IF root

}

restart() {

    stop
    sleep 1
    start

}

show() {

    $TC -s qdisc ls dev $IF

}

case "$1" in

  scenario_1)
  while :
  do
    echo "Starting bandwidth shaping: "
    initial
    start
    echo "Current speed: $DNLD"
    echo "Will sleep for $TIMER"
    sleep $TIMER

    echo "Downgrading to 3G"
    Speed_3G
    start
    echo "Current speed: $DNLD"
    echo "Enjoy 3G Speed!"
    sleep $TIMER

    echo "Downgrading to 2G"
    Speed_2G
    start
    echo "Current speed: $DNLD"
    echo "Die in 2G Speed!"
    sleep $TIMER
  done
    ;;

  scenario_2)
    while :
      do
        echo "Running in 4G Speed"
        initial
        start
        echo "Current speed: $DNLD"
        echo "Will sleep for $TIMER"
        sleep $TIMER

        echo "Downgrading to 3G"
        Speed_3G
        start
        echo "Current speed: $DNLD"
        echo "Enjoy 3G Speed!"
        sleep $TIMER

        echo "Downgrading to 2G"
        Speed_2G
        start
        echo "Current speed: $DNLD"
        echo "Die in 2G Speed!"
        sleep $TIMER

        echo "Upgrading to 3G"
        Speed_3G
        start
        echo "Current Speed: $DNLD"
        echo "Enjoy 3G Speed!"
        sleep $TIMER
      done
    ;;

  stop)

    echo "Stopping bandwidth shaping: "
    stop
    echo "done"
    ;;

  restart)

    echo "Restarting bandwidth shaping: "
    restart
    echo "done"
    ;;

  show)

    echo "Bandwidth shaping status for $IF:\n"
    show
    echo ""
    ;;
  scenario_3)
      echo "Starting at a constant speed"
      start
      echo "Download speed $DNLD"
      ;;

      scenario_4)
      while :
      do
        echo "Running in $DNLD Mbps speed..."
        initial
        start
        #echo "Current speed: $DNLD"
        echo "Will sleep for $TIMER..."
        sleep $TIMER

        echo "Downgrading to $DNLD Mbps..."
        Speed_3G
        start
        #echo "Current speed: $DNLD"
        #echo "Die in 2G Speed!"
        sleep $TIMER

        echo "No network!!"
        No_Network
        start
        echo "Current speed: $DNLD"
        echo "-------*****************------"
        sleep $TIMER
      done
      ;;

  *)

    pwd=$(pwd)
    echo "Usage: $(/usr/bin/dirname $pwd)/tc.bash {start|stop|restart|show}"
    ;;

esac

exit 0
