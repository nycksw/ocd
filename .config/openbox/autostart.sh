# ~eater/.config/openbox/autostart.sh
# http://eater.org/

xsetroot -solid black

. $GLOBALAUTOSTART

ln -sf ~/.bgimg-$(hostname -f) ~/.bgimg
ln -sf ~/.synergyrc-$(hostname -f) ~/.synergyrc

xset fp+ ~/.fonts
xset fp rehash
xset b off
xset m 2 1.6

if [ -f ~/.synergy-$(hostname -f) ];then
  sh ~/.synergy-$(hostname -f) &
fi

xscreensaver -nosplash &

which pypanel && (sleep 2 && pypanel) &
which fbsetbg && (sleep 5 && fbsetbg ~/.bgimg) &
