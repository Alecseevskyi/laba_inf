#!/bin/bash

touch notes.txt

echo "enter text (for exit print 'exit'): "

read line

while test "$line" != "exit"; do
	echo "$line" >> notes.txt
	read line
done

echo "file contains: "
cat notes.txt

rm notes.txt
echo "file notes.txt was delete"

