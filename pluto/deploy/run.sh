#!/bin/sh
# Lançado pelo init na serial USB do Pluto (ttyGS0), no lugar do getty.
# stdin/stdout são a serial que vai ao ESP32; os erros vão para /tmp/sdr.log.
#
# Para voltar ao login antigo nessa serial:  touch /mnt/jffs2/sdr/off   e reinicie.
# O login continua sempre disponível na outra USB-C (console, ttyPS0) e pelo SSH.

D=/mnt/jffs2/sdr

# Se o programa cair, o init o reinicia; a pausa evita reinícios em rajada.
sleep 1

# Programa novo pelo cartão (Ajustes > Pluto pelo cartão no ESP32): ele deixa o arquivo "novo" ao se
# instalar e o apaga quando se confirma (desde 03/11/2026: 30 s rodando e ter respondido ao ESP32; mudo com o
# ESP32 falando, ele sai sozinho). Sem confirmação em 3 partidas seguidas, volta ao anterior (rx_old), e o
# arquivo "voltou" conta isso ao programa (que conta ao ESP32). Só comentário mudou: não precisa reinstalar.
voltar() {
  cp "$D/rx_old" "$D/rx_tmp" && chmod +x "$D/rx_tmp" && mv "$D/rx_tmp" "$D/rx_streaming_fft"
  rm -f "$D/novo"
  touch "$D/voltou"
  sync
  echo "run.sh: $1; voltou ao programa anterior" >> /tmp/sdr.log
}
if [ -e "$D/novo" ]; then
  n=$(cat "$D/novo" 2>/dev/null)
  case "$n" in ''|*[!0-9]*) n=0 ;; esac
  n=$((n + 1))
  if [ "$n" -ge 3 ] && [ -x "$D/rx_old" ]; then
    voltar "o programa novo nao subiu em 3 partidas"
  else
    echo "$n" > "$D/novo"
  fi
fi
if [ ! -x "$D/rx_streaming_fft" ] && [ -x "$D/rx_old" ]; then
  voltar "faltava o programa"
fi

if [ -e "$D/off" ] || [ ! -x "$D/rx_streaming_fft" ]; then
  exec /sbin/getty -L ttyGS0 0 vt100
fi

# O boot do Pluto liga só um dos dois núcleos do Zynq (maxcpus=1 na linha do kernel). O segundo
# fica para a FFT do espectro integrado; some no reboot e é ligado de novo aqui. Para ficar com
# um núcleo só:  touch /mnt/jffs2/sdr/um_nucleo
if [ ! -e "$D/um_nucleo" ] && [ -w /sys/devices/system/cpu/cpu1/online ]; then
  echo 1 > /sys/devices/system/cpu/cpu1/online 2>/dev/null
fi

exec "$D/rx_streaming_fft" 2>>/tmp/sdr.log
