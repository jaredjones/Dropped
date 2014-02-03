#!/bin/bash


cat big.dic | while read line
do
#echo "$line"
sqlite3 Dropped.db "INSERT OR IGNORE INTO words(word) values('$line');"
done
