#! /bin/bash

for LAYOUT in singet noniiruto naginata nicola tuki-2-263 gekkou-20211106 roman-tomisuke roman-oonishi roman-qwerty phoenix_rt sou-code g-code t-code tutr-code tut-code; do
    echo "---- $LAYOUT ----"
    tail -n 1 debug/debug_$LAYOUT.log
done

