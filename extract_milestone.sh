#! /bin/bash

echo "---- naginata ----"
egrep '^([0-9]+: |score = )' debug_naginata.log
echo "---- singeta ----"
egrep '^([0-9]+: |score = )' debug_singeta.log
echo "---- noniiruto ----"
egrep '^([0-9]+: |score = )' debug_noniiruto.log

