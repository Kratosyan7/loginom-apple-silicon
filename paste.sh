#!/bin/bash
# Кладёт буфер обмена мака в буфер контейнера: потом в Loginom нажать Ctrl+V.
pbpaste | docker exec -i -e DISPLAY=:1 loginom sh -c 'xclip -i -selection clipboard -t UTF8_STRING; true'
echo "Готово: в окне Loginom нажмите Ctrl+V"
