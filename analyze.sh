#! /bin/bash

mkdir -p debug
for LAYOUT in singet noniiruto naginata nicola tuki-2-263 gekkou-20211106 roman-tomisuke roman-oonishi roman-qwerty phoenix_rt sou-code g-code t-code tutr-code tut-code; do
    echo "---- $LAYOUT ----"
    LOG_FILE=/dev/null
    if [ "$DEBUG" ]; then
        LOG_FILE=debug/debug_$LAYOUT.log
    fi
    ruby analyze_bimora_time.rb tables/$LAYOUT.tbl.txt 2> $LOG_FILE
done

