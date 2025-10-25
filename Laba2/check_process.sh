#!/bin/bash

echo "enter process name: "
read process

#ищет процессы по имени
pgrep $process > /dev/null
# /dev/null убирает лишнюю информацию

if  [ $? -eq 0 ]; then
	echo "process is working"
else
	echo "process not found"
fi
