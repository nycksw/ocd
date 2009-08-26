# ~eater/.xsession
# http://eater.org/

ln -sf .bgimg-$(hostname -f) .bgimg
ln -sf .synergyrc-$(hostname -f) .synergyrc

xset fp+ ~/.fonts
xset fp rehash
xset -b
xset m 2 1.6

if [ -f ~/.synergy-$(hostname -f) ];then
  sh ~/.synergy-$(hostname -f)
fi

if [ -f ~/.Xdefaults ]; then
  xrdb -merge ~/.Xdefaults
fi
