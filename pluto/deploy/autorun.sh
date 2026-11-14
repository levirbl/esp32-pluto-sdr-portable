# /mnt/jffs2/autorun.sh — executado no boot pelo /etc/init.d/S98autostart (com "source",
# por isso este arquivo não usa exit).
#
# A raiz do Pluto roda em RAM: a troca no /etc/inittab precisa ser refeita a cada boot.
# Ela põe o run.sh do SDR no lugar do getty da serial USB (ttyGS0).

if [ -x /mnt/jffs2/sdr/run.sh ] && [ ! -e /mnt/jffs2/sdr/off ]; then
  sed -i 's|^ttyGS0::respawn:.*|ttyGS0::respawn:/mnt/jffs2/sdr/run.sh|' /etc/inittab
  kill -HUP 1
  # Se o getty da ttyGS0 já estiver rodando, encerra; o init não o recria mais.
  (
    sleep 3
    for p in $(pidof getty); do
      grep -q ttyGS0 /proc/$p/cmdline 2>/dev/null && kill $p
    done
  ) &
fi
