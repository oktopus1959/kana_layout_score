#! /bin/bash

ruby analyze_bimora_time.rb tables/naginata.tbl.txt 2> debug_naginata.log
ruby analyze_bimora_time.rb tables/singet.tbl.txt 2> debug_singeta.log
ruby analyze_bimora_time.rb tables/noniiruto.tbl.txt 2> debug_noniiruto.log

