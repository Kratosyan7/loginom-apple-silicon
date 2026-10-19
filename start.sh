#!/bin/bash
# чистим локи прошлого запуска, иначе Xvfb не займёт :1
rm -f /tmp/.X*-lock /tmp/.X11-unix/X* 2>/dev/null

# -noreset: без него Xvfb сбрасывает раскладку, когда отключается последний
# клиент, и setxkbmap ниже (он запускается первым) ни на что не влияет
Xvfb :1 -screen 0 1600x1000x24 -nolisten tcp -noreset &
for i in $(seq 1 60); do [ -e /tmp/.X11-unix/X1 ] && break; sleep 0.5; done

# раскладка uscyr: латиница и кириллица на одних клавишах (кириллица на уровне
# AltGr). В us,ru x11vnc не находил русские буквы во второй группе, а
# динамически добавленных кейкодов хватало ненадолго
cat > /usr/share/X11/xkb/symbols/uscyr <<'XKB'
default partial alphanumeric_keys
xkb_symbols "basic" {
    include "us"
    include "level3(ralt_switch)"
    key <TLDE> { [ grave, asciitilde, Cyrillic_io, Cyrillic_IO ] };
    key <AD01> { [ q, Q, Cyrillic_shorti, Cyrillic_SHORTI ] };
    key <AD02> { [ w, W, Cyrillic_tse, Cyrillic_TSE ] };
    key <AD03> { [ e, E, Cyrillic_u, Cyrillic_U ] };
    key <AD04> { [ r, R, Cyrillic_ka, Cyrillic_KA ] };
    key <AD05> { [ t, T, Cyrillic_ie, Cyrillic_IE ] };
    key <AD06> { [ y, Y, Cyrillic_en, Cyrillic_EN ] };
    key <AD07> { [ u, U, Cyrillic_ghe, Cyrillic_GHE ] };
    key <AD08> { [ i, I, Cyrillic_sha, Cyrillic_SHA ] };
    key <AD09> { [ o, O, Cyrillic_shcha, Cyrillic_SHCHA ] };
    key <AD10> { [ p, P, Cyrillic_ze, Cyrillic_ZE ] };
    key <AD11> { [ bracketleft, braceleft, Cyrillic_ha, Cyrillic_HA ] };
    key <AD12> { [ bracketright, braceright, Cyrillic_hardsign, Cyrillic_HARDSIGN ] };
    key <AC01> { [ a, A, Cyrillic_ef, Cyrillic_EF ] };
    key <AC02> { [ s, S, Cyrillic_yeru, Cyrillic_YERU ] };
    key <AC03> { [ d, D, Cyrillic_ve, Cyrillic_VE ] };
    key <AC04> { [ f, F, Cyrillic_a, Cyrillic_A ] };
    key <AC05> { [ g, G, Cyrillic_pe, Cyrillic_PE ] };
    key <AC06> { [ h, H, Cyrillic_er, Cyrillic_ER ] };
    key <AC07> { [ j, J, Cyrillic_o, Cyrillic_O ] };
    key <AC08> { [ k, K, Cyrillic_el, Cyrillic_EL ] };
    key <AC09> { [ l, L, Cyrillic_de, Cyrillic_DE ] };
    key <AC10> { [ semicolon, colon, Cyrillic_zhe, Cyrillic_ZHE ] };
    key <AC11> { [ apostrophe, quotedbl, Cyrillic_e, Cyrillic_E ] };
    key <AB01> { [ z, Z, Cyrillic_ya, Cyrillic_YA ] };
    key <AB02> { [ x, X, Cyrillic_che, Cyrillic_CHE ] };
    key <AB03> { [ c, C, Cyrillic_es, Cyrillic_ES ] };
    key <AB04> { [ v, V, Cyrillic_em, Cyrillic_EM ] };
    key <AB05> { [ b, B, Cyrillic_i, Cyrillic_I ] };
    key <AB06> { [ n, N, Cyrillic_te, Cyrillic_TE ] };
    key <AB07> { [ m, M, Cyrillic_softsign, Cyrillic_SOFTSIGN ] };
    key <AB08> { [ comma, less, Cyrillic_be, Cyrillic_BE ] };
    key <AB09> { [ period, greater, Cyrillic_yu, Cyrillic_YU ] };
};
XKB
setxkbmap -layout uscyr

fluxbox >/dev/null 2>&1 &

# мост между CLIPBOARD и PRIMARY, без него буфер обмена
# синхронизируется с macOS только наполовину
autocutsel -selection CLIPBOARD >/dev/null 2>&1 &
autocutsel -selection PRIMARY >/dev/null 2>&1 &

mkdir -p /root/.vnc
x11vnc -storepasswd loginom /root/.vnc/passwd >/dev/null 2>&1
# -remap: Unicode-коды русских букв (0x10004xx) переводятся в обычные кейсимы
# (0x6c0-0x6ff), которые есть в uscyr
REMAP="0x100044e-0x6c0,0x1000430-0x6c1,0x1000431-0x6c2,0x1000446-0x6c3,0x1000434-0x6c4,0x1000435-0x6c5,0x1000444-0x6c6,0x1000433-0x6c7,0x1000445-0x6c8,0x1000438-0x6c9,0x1000439-0x6ca,0x100043a-0x6cb,0x100043b-0x6cc,0x100043c-0x6cd,0x100043d-0x6ce,0x100043e-0x6cf,0x100043f-0x6d0,0x100044f-0x6d1,0x1000440-0x6d2,0x1000441-0x6d3,0x1000442-0x6d4,0x1000443-0x6d5,0x1000436-0x6d6,0x1000432-0x6d7,0x100044c-0x6d8,0x100044b-0x6d9,0x1000437-0x6da,0x1000448-0x6db,0x100044d-0x6dc,0x1000449-0x6dd,0x1000447-0x6de,0x100044a-0x6df,0x100042e-0x6e0,0x1000410-0x6e1,0x1000411-0x6e2,0x1000426-0x6e3,0x1000414-0x6e4,0x1000415-0x6e5,0x1000424-0x6e6,0x1000413-0x6e7,0x1000425-0x6e8,0x1000418-0x6e9,0x1000419-0x6ea,0x100041a-0x6eb,0x100041b-0x6ec,0x100041c-0x6ed,0x100041d-0x6ee,0x100041e-0x6ef,0x100041f-0x6f0,0x100042f-0x6f1,0x1000420-0x6f2,0x1000421-0x6f3,0x1000422-0x6f4,0x1000423-0x6f5,0x1000416-0x6f6,0x1000412-0x6f7,0x100042c-0x6f8,0x100042b-0x6f9,0x1000417-0x6fa,0x1000428-0x6fb,0x100042d-0x6fc,0x1000429-0x6fd,0x1000427-0x6fe,0x100042a-0x6ff,0x1000451-0x6a3,0x1000401-0x6b3"
x11vnc -display :1 -forever -shared -threads -modtweak -add_keysyms \
       -remap "$REMAP" \
       -rfbauth /root/.vnc/passwd -rfbport 5900 -quiet >/dev/null 2>&1 &

# профиль box64 для CEF, по аналогии со штатными профилями chrome/ONLYOFFICE
export BOX64_LIBCEF=1
export BOX64_NOSANDBOX=1
export BOX64_INPROCESSGPU=1
export BOX64_EMULATED_LIBS=libtcmalloc_minimal.so.4
export BOX64_LD_LIBRARY_PATH=/opt/loginom/lib:/opt/loginom/cef

cd /opt/loginom
exec /usr/local/bin/box64 ./loginom --no-sandbox --disable-gpu --disable-dev-shm-usage
