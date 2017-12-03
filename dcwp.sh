#!/usr/bin/env bash

if [ -z "$1" ]
 then
    echo "Please add site name. i.e: eecreate sitename --wp";
fi

sitename=$1;

sed "s/{domain_name}/$sitename/g" ./config/templates/virtualhost > ./config/nginx/sites-available/$sitename

mkdir www/$sitename
mkdir www/$sitename/conf
mkdir www/$sitename/htdocs
mkdir www/$sitename/logs

docker-compose exec --user root nginx ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/$sitename
docker-compose exec --user root nginx service nginx restart

if [ ! -z "$2" ]
	then
		echo "$2" | sudo -S sh -c "echo '127.0.0.1 $sitename' >> /etc/hosts";
fi
#sudo ee site create $sitename $type;