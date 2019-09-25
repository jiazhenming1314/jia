#!/bin/bash
while inotifywait -rqq /opt 
do
	rsync -az --delete /opt/  root@192.168.11.22:/opt/  
done
