#!/usr/bin/env bash

if [ -z "$1" ]
 then
    echo "Please add site name. i.e: dcwp example.dev create";
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
action="create"

dbname=$( echo "$sitename" | sed 's/\./_/g'  | sed 's/\-/_/g' )

if [ ! -z "$2" ]
then
	action="$2"
fi

if [ "$action" == "create" ]
	then
		if [ -f "$DIR/config/nginx/sites-available/$sitename" ];
			then
				echo "Site is already exist."
				exit;
		fi
		sed "s/{domain_name}/$sitename/g" $DIR/config/templates/virtualhost > $DIR/config/nginx/sites-available/$sitename
		docker-compose -f $DIR/docker-compose.yml exec --user root mysql mysql -u root -ppassword -e "create database $dbname;";


		mkdir $DIR/www/$sitename
		mkdir $DIR/www/$sitename/conf
		mkdir $DIR/www/$sitename/htdocs
		mkdir $DIR/www/$sitename/logs
		touch $DIR/www/$sitename/logs/access.log
		touch $DIR/www/$sitename/logs/error.log

		chown -R www-data: $DIR/www/

		docker-compose -f $DIR/docker-compose.yml exec --user root nginx ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/$sitename
		docker-compose -f $DIR/docker-compose.yml exec --user root nginx service nginx restart

		sitepath="$DIR/www/$sitename/htdocs"
		wpsitepath="/var/www/$sitename/htdocs"

		if [ -f "$sitepath/wp-config.php" ];
		then
			echo "WordPress config file found."
		else
			echo "WordPress config file not found. Installing..."
			docker-compose -f $DIR/docker-compose.yml exec --user www-data phpfpm wp core --path=$wpsitepath download
			docker-compose -f $DIR/docker-compose.yml exec --user www-data phpfpm wp core --path=$wpsitepath config --dbhost=mysql --dbname=$dbname --dbuser=root --dbpass=password
			docker-compose -f $DIR/docker-compose.yml exec --user www-data phpfpm wp core --path=$wpsitepath install --url="$sitename" --skip-email=y --prompt=title,admin_user,admin_password,admin_email
		fi

		if [ ! -z "$3" ]
			then
				echo "$3" | sudo -S sh -c "echo '127.0.0.1 $sitename' >> /etc/hosts";
		fi
elif [ "$action" == "delete" ]
then
	if [ ! -f "$DIR/config/nginx/sites-available/$sitename" ];
		then
			echo "Sorry, this site is not available."
			exit;
	fi

	rm $DIR/config/nginx/sites-available/$sitename

	rm -rf $DIR/www/$sitename

	docker-compose -f $DIR/docker-compose.yml exec --user root mysql mysql -u root -ppassword -e "drop database if exists $dbname;";
elif [ "$action" == "list" ]
then
	for entry in "$DIR/config/nginx/sites-available"/*
	do
	  echo ${entry##*/}
	done
elif [ "$action" == "createempty" ]
then
	if [ -f "$DIR/config/nginx/sites-available/$sitename" ];
		then
			echo "Site is already exist."
			exit;
	fi
	sed "s/{domain_name}/$sitename/g" $DIR/config/templates/virtualhost > $DIR/config/nginx/sites-available/$sitename


	mkdir $DIR/www/$sitename
	mkdir $DIR/www/$sitename/conf
	mkdir $DIR/www/$sitename/htdocs
	mkdir $DIR/www/$sitename/logs

	chown -R www-data: $DIR/www/

	docker-compose -f $DIR/docker-compose.yml exec --user root nginx ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/$sitename
	docker-compose -f $DIR/docker-compose.yml exec --user root nginx service nginx restart

	if [ ! -z "$3" ]
		then
			echo "$3" | sudo -S sh -c "echo '127.0.0.1 $sitename' >> /etc/hosts";
	fi
fi
