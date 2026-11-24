# eeeshe

SHE (Super Hybrid Engine) hotkey scripts for ASUS Eee PC.

`she-cycle.sh` cycles the CPU performance mode through the modes exposed by
the `eeepc_laptop` (or `eeepc-wmi`) driver and shows a desktop notification
with the new mode.  It is meant to be triggered by the Fn-Space ACPI event,
but can also be run by hand.

## Requirements

- Linux with the `eeepc_laptop` or `eeepc-wmi` kernel module
  (`/sys/devices/platform/eeepc/cpufv`).
- `acpid` to react to the Fn-Space ACPI event.
- XFCE with `xfce4-notifyd` for the on-screen notification.
- `sudo`, used to send the notification as the logged-in X user.

The script must run as root: `cpufv` is only writable by root.

## Installation

Clone the repository:

```
git clone https://github.com/Merennor/eeeshe.git
cd eeeshe
```

Install the ACPI action and event:

```
sudo install -m 755 she-cycle.sh /etc/acpi/actions/she-cycle.sh
sudo install -m 644 she /etc/acpi/events/she
sudo systemctl restart acpid   # or: sudo service acpid restart
```

To run it manually:

```
sudo ./she-cycle.sh
```

## How it works

`cpufv` reports `(mode_count << 8) | current_mode`, for example `0x301`
means three modes with mode 1 selected.  Modes are 0-based and, on the
1001PXD, are `0 = Performance`, `1 = Normal`, `2 = Powersave`.

## Compatibility

Tested on an ASUS Eee PC 1001PXD (Arch Linux, kernel 7.3.5-zen) with XFCE.
Other models exposing the same `cpufv` interface should work.  The kernel
driver disables `cpufv` on the 701/702, where the script simply exits.
