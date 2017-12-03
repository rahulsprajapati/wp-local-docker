#!/usr/bin/env bash

if [ -z "$1" ]
 then
    echo "Please add site name. i.e: dcwp example.dev create";
    exit;
fi

sitename=$1
action="create"

dbname=$( echo "$sitename" | sed 's/\./_/g')

if [ ! -z "$2" ]
then
	action="$2"
fi

if [ "$action" == "create" ]
	then
		if [ -f "./config/nginx/sites-available/$sitename" ];
			then
				echo "Site is already exist."
				exit;
		fi
		sed "s/{domain_name}/$sitename/g" ./config/templates/virtualhost > ./config/nginx/sites-available/$sitename
		docker-compose exec --user root mysql mysql -u root -ppassword -e "create database $dbname;";


		mkdir www/$sitename
		mkdir www/$sitename/conf
		mkdir www/$sitename/htdocs
		mkdir www/$sitename/logs

		docker-compose exec --user root nginx ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/$sitename
		docker-compose exec --user root nginx service nginx restart

		sitepath="./www/$sitename/htdocs"
		wpsitepath="/var/www/$sitename/htdocs"

		if [ -f "$sitepath/wp-config.php" ];
		then
			echo "WordPress config file found."
		else
			echo "WordPress config file not found. Installing..."
			docker-compose exec --user www-data phpfpm wp core --path=$wpsitepath download
			docker-compose exec --user www-data phpfpm wp core --path=$wpsitepath config --dbhost=mysql --dbname=$dbname --dbuser=root --dbpass=password
			docker-compose exec --user www-data phpfpm wp core --path=$wpsitepath install --url=$sitename --prompt
		fi

		if [ ! -z "$3" ]
			then
				echo "$3" | sudo -S sh -c "echo '127.0.0.1 $sitename' >> /etc/hosts";
		fi
	elif [ "$action" == "delete" ]
	then
		if [ ! -f "./config/nginx/sites-available/$sitename" ];
			then
				echo "Sorry, this site is not available."
				exit;
		fi

		rm ./config/nginx/sites-available/$sitename

		rm -rf www/$sitename

		docker-compose exec --user root mysql mysql -u root -ppassword -e "drop database if exists $dbname;";
	elif [ "$action" == "list" ]
	then
		for entry in "./config/nginx/sites-available"/*
		do
		  echo ${entry##*/}
		done
fi
