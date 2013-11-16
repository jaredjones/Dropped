#!/bin/bash


cat US.dic | while read line
do
#echo "$line"
sqlite3 Dropped.db "INSERT INTO words(word) values('$line');"
done
