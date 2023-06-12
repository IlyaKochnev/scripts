#!/usr/bin/env bash

for i in "$@";
do

# youtube-dl \
yt-dlp \
--username axessman@gmail.com \
--password "%*U@zdHeC59b59rBG^@Ga" \
"$i" \
-o "~/Videos/%(playlist)s/%(chapter_number)02d - %(chapter)s/%(playlist_index)02d - %(title)s.%(ext)s" \
--sleep-interval 35 \
--max-sleep-interval 120 \
--rate-limit 254976 \
--user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36" \\
--sub-lang ru \
# --list-subs \
--sub-format srt \
--verbose \
--cookies "./cookies.txt" \
--write-sub

done