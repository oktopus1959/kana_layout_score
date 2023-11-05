#! /bin/bash

for LAYOUT in naginata singet noniiruto nicola roman phoenix_rt tuki-2-263 gekkou-20211106; do
    echo "---- $LAYOUT ----"
    ruby analyze_bimora_time.rb tables/$LAYOUT.tbl.txt 2> debug_$LAYOUT.log
done

