# ~eater/.config/openbox/autostart.sh
# http://eater.org/

. $GLOBALAUTOSTART

xset fp+ ~/.fonts
xset fp rehash
xset b off
xset m 2 1.6

xscreensaver -nosplash &

which pypanel && (sleep 2 && pypanel) &
which osd_clock && osd_clock -t -r -c grey -s3 &
