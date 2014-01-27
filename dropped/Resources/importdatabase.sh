#!/bin/bash


cat big.dic | while read line
do
#echo "$line"
sqlite3 Dropped.db "INSERT INTO words(word) values('$line');"
done
