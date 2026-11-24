#!/bin/bash
# Cycle the Eee PC "Super Hybrid Engine" CPU mode (SHE hotkey).
#
# The sysfs value is (mode_count << 8) | current_mode, e.g. 0x301 means
# 3 modes with mode 1 selected.  Modes are 0-based: 0 = Performance,
# 1 = Normal, 2 = Powersave on the 1001PXD.

set -u
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

# ---- locate the sysfs interface -------------------------------------------
CPUFV=
for p in /sys/devices/platform/eeepc/cpufv \
         /sys/devices/platform/eeepc-wmi/cpufv \
         /sys/devices/platform/eeepc-laptop/cpufv; do
	[[ -e $p ]] && { CPUFV=$p; break; }
done
[[ -n $CPUFV && -r $CPUFV && -w $CPUFV ]] || exit 1

# ---- serialise concurrent presses -----------------------------------------
if command -v flock >/dev/null 2>&1 && [[ -w /run ]]; then
	exec 9>/run/she-cycle.lock || exit 1
	flock -n 9 || exit 0
fi

# ---- read / cycle ---------------------------------------------------------
read -r RAW < "$CPUFV" || exit 1
[[ $RAW =~ ^(0[xX][0-9a-fA-F]+|[0-9]+)$ ]] || exit 1
RAW=$(( RAW ))

AVAILABLE=$(( (RAW >> 8) & 0xFF ))
CURRENT=$(( RAW & 0xFF ))
(( AVAILABLE > 0 )) || exit 1

NEXT=$(( (CURRENT + 1) % AVAILABLE ))
LABELS=(Performance Normal Powersave)
LABEL=${LABELS[$NEXT]:-Mode $NEXT}

printf '%d\n' "$NEXT" > "$CPUFV" || exit 1

# ---- notify the XFCE session ----------------------------------------------
read -r user disp <<<"$(who | awk '
	{
		d = ($2 ~ /^:[0-9]+(\.[0-9]+)?$/) ? $2 : $NF
		gsub(/[()]/, "", d)
		if (d ~ /^:[0-9]+(\.[0-9]+)?$/) { print $1, d; exit }
	}')"
[[ -n $user && -n $disp ]] || exit 0

session=$(pgrep -n -u "$user" -x xfce4-session) || exit 0
dbus=$(tr '\0' '\n' < "/proc/$session/environ" 2>/dev/null |
       sed -n 's/^DBUS_SESSION_BUS_ADDRESS=//p')
[[ -n $dbus ]] || exit 0

command -v notify-send >/dev/null 2>&1 || exit 0
sudo -u "$user" env DISPLAY="$disp" DBUS_SESSION_BUS_ADDRESS="$dbus" \
	notify-send -t 1500 -i battery "SHE" "$LABEL"
