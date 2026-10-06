#!/bin/bash
# Переключает Caps Lock внутри Loginom, если он рассинхронизировался с маком.
docker exec loginom sh -c 'DISPLAY=:1 xdotool key Caps_Lock && python3 -c "
import ctypes
x=ctypes.CDLL(\"libX11.so.6\"); x.XOpenDisplay.restype=ctypes.c_void_p
d=x.XOpenDisplay(b\":1\"); s=ctypes.c_uint()
x.XkbGetIndicatorState(ctypes.c_void_p(d),0x100,ctypes.byref(s))
print(\"Caps Lock в Loginom: ВКЛ\" if s.value&1 else \"Caps Lock в Loginom: выкл\")"'
