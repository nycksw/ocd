# ~eater/.config/openbox/autostart.sh
# http://eater.org/

#. $GLOBALAUTOSTART

xset b off
xset m 2 1.6

xscreensaver -nosplash &
gnome-settings-daemon &
feh --bg-scale $HOME/.background &
