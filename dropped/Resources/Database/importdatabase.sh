#!/bin/bash


cat en-us2.dic | while read line
do
#echo "$line"
sqlite3 en.db "INSERT OR IGNORE INTO words(word) values('$line');"
done
