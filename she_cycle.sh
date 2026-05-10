#!/bin/bash

CPUFV=/sys/devices/platform/eeepc/cpufv
[[ -f $CPUFV ]] || exit 1

RAW=$(cat $CPUFV)
AVAILABLE=$(( RAW >> 8 ))
CURRENT=$(( RAW & 0xFF ))
NEXT=$(( (CURRENT + 1) % AVAILABLE ))

case $NEXT in
  0) LABEL="Performance" ;;
  1) LABEL="Normal"      ;;
  2) LABEL="Powersave"   ;;
  *) LABEL="Mode $NEXT"  ;;
esac

echo $NEXT > $CPUFV

XUSER=$(who | awk '/(:0)/{print $1; exit}')
DBUS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u "$XUSER" xfce4-session)/environ | tr -d '\0' | cut -d= -f2-)

sudo -u "$XUSER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="$DBUS" notify-send -t 1500 -i battery "SHE" "$LABEL"
