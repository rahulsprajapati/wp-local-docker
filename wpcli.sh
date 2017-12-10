#!/usr/bin/env bash

if [ -z "$1" ]
 then
    echo "Please add site name. i.e: wpcli example.dev post list";
    exit;
fi

file="$0"
if [[ -L "$file" ]]
then
    FILE_PATH=$(readlink "${0}")
    DIR=$(dirname "${FILE_PATH}")
else
    DIR="."
fi

if [ ! "$(docker ps -q -f name=nginx)" ]; then
	echo "Docker container are not running. Wait a min let me run that for you...";
	docker-compose -f $DIR/docker-compose.yml up -d
fi

sitename=$1

if [ ! -f "$DIR/config/nginx/sites-available/$sitename" ];
	then
		echo "Site does not exist."
		exit;
fi
wpsitepath="/var/www/$sitename/htdocs"

docker-compose -f $DIR/docker-compose.yml exec --user www-data phpfpm wp --path=$wpsitepath "${@:2}"
