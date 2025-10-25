#!/bin/bash
echo "enter message: "
read message

echo "send message to server..."
 
	echo "$message" | nc localhost 12345

echo "message send!"

