# arm64-база: инфраструктура работает нативно, эмулируется только Loginom
FROM --platform=linux/arm64 debian:12

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    LANG=ru_RU.UTF-8 \
    LC_ALL=ru_RU.UTF-8

# нативные arm64: X-сервер, WM, VNC + инструменты сборки box64
RUN apt-get update && apt-get install -y --no-install-recommends \
      xvfb x11vnc fluxbox locales ca-certificates \
      git cmake build-essential python3 \
      fonts-dejavu fonts-liberation \
    && sed -i 's/# ru_RU.UTF-8/ru_RU.UTF-8/' /etc/locale.gen && locale-gen \
    && rm -rf /var/lib/apt/lists/*

# box64 собирается нативно под arm64 — это быстро
RUN git clone --depth 1 https://github.com/ptitSeb/box64 /tmp/box64 \
    && mkdir -p /tmp/box64/build && cd /tmp/box64/build \
    && cmake .. -DARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && make -j"$(nproc)" && make install \
    && rm -rf /tmp/box64

# x86-64 библиотеки, которые нужны бинарнику Loginom, через multiarch
RUN dpkg --add-architecture amd64 && apt-get update && apt-get install -y --no-install-recommends \
      libgtk-3-0:amd64 libnss3:amd64 libxss1:amd64 libasound2:amd64 libxtst6:amd64 \
      libgbm1:amd64 libx11-xcb1:amd64 libxcomposite1:amd64 libxdamage1:amd64 \
      libxrandr2:amd64 libxi6:amd64 libcups2:amd64 libatk1.0-0:amd64 \
      libatk-bridge2.0-0:amd64 libpango-1.0-0:amd64 libpangocairo-1.0-0:amd64 \
      libcairo2:amd64 libdrm2:amd64 libexpat1:amd64 libdbus-1-3:amd64 \
      libnspr4:amd64 libglib2.0-0:amd64 libgl1:amd64 libglu1-mesa:amd64 \
      libmariadb3:amd64 \
    && rm -rf /var/lib/apt/lists/*

# нативные arm64 GTK/GLib/ATK/Wayland — box64 оборачивает их вместо трансляции.
# -dev пакеты нужны ради безверсионных симлинков (libgtk-3.so), которые box64 ищет по имени.
RUN apt-get update && apt-get install -y --no-install-recommends \
      libgtk-3-dev libatk1.0-dev libatk-bridge2.0-dev libatspi2.0-dev \
      libxkbcommon-dev libwayland-dev libxcursor-dev libxcomposite-dev \
      libglib2.0-dev libcairo2-dev libpango1.0-dev \
      libtcmalloc-minimal4 libnss3 x11-apps netpbm \
      autocutsel xdotool xclip \
    && rm -rf /var/lib/apt/lists/*

# команда снимка экрана: сохраняет PNG в общую папку /data
RUN printf '%s\n' \
  '#!/bin/bash' \
  'OUT="${1:-/data/screenshot-$(date +%Y%m%d-%H%M%S).png}"' \
  'DISPLAY=:1 xwd -root | xwdtopnm | pnmtopng > "$OUT" 2>/dev/null' \
  'echo "$OUT"' \
  > /usr/local/bin/screenshot && chmod +x /usr/local/bin/screenshot

# /data видна в боковой панели диалога выбора файла и в домашней папке
RUN mkdir -p /root/.config/gtk-3.0 \
    && printf 'file:///data %s\n' 'Данные' > /root/.config/gtk-3.0/bookmarks \
    && ln -sfn /data /root/data

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5900
CMD ["/usr/local/bin/start.sh"]
