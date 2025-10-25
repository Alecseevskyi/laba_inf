#!/bin/bash

echo "enter number"
read num

i=$num

while [ $i -gt 0 ]; do
	echo $i
	i=$(($i-1))
done
echo "done!"
