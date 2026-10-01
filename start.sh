#!/bin/bash
# чистим локи прошлого запуска, иначе Xvfb не займёт :1
rm -f /tmp/.X*-lock /tmp/.X11-unix/X* 2>/dev/null

Xvfb :1 -screen 0 1600x1000x24 -nolisten tcp &
for i in $(seq 1 60); do [ -e /tmp/.X11-unix/X1 ] && break; sleep 0.5; done

fluxbox >/dev/null 2>&1 &

# мост между CLIPBOARD и PRIMARY, без него буфер обмена
# синхронизируется с macOS только наполовину
autocutsel -selection CLIPBOARD >/dev/null 2>&1 &
autocutsel -selection PRIMARY >/dev/null 2>&1 &

mkdir -p /root/.vnc
x11vnc -storepasswd loginom /root/.vnc/passwd >/dev/null 2>&1
x11vnc -display :1 -forever -shared -threads \
       -rfbauth /root/.vnc/passwd -rfbport 5900 -quiet >/dev/null 2>&1 &

# профиль box64 для CEF, по аналогии со штатными профилями chrome/ONLYOFFICE
export BOX64_LIBCEF=1
export BOX64_NOSANDBOX=1
export BOX64_INPROCESSGPU=1
export BOX64_EMULATED_LIBS=libtcmalloc_minimal.so.4
export BOX64_LD_LIBRARY_PATH=/opt/loginom/lib:/opt/loginom/cef

cd /opt/loginom
exec /usr/local/bin/box64 ./loginom --no-sandbox --disable-gpu --disable-dev-shm-usage
