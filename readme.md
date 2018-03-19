# [Customized for Multiple sites] WordPress Docker Development Environment

Tested only on MAC. I'm using this for my local development only. 

This is a forked repo of 10up wp local docker with updated script for adding new sites in one instance for local development of wordpress.

## What's Inside

This project is based on [docker-compose](https://docs.docker.com/compose/). By default, the following containers are started: PHP-FPM, MariaDB, Elasticsearch, nginx, and Memcached. The `/wordpress` directory is the web root which is mapped to the nginx container.

You can directly edit PHP, nginx, and Elasticsearch configuration files from within the repo as they are mapped to the correct locations in containers.

A [custom phpfpm image](https://github.com/10up/phpfpm-image) is used for this environment that adds a few extra things to the PHP-FPM image.

The `/config/elasticsearch/plugins` folder is mapped to the plugins folder in the Elasticsearch container. You can drop Elasticsearch plugins in this folder to have them installed within the container.

## Requirements

* [Docker](https://www.docker.com/)
* [docker-compose](https://docs.docker.com/compose/)

## Setup

1. `git clone https://github.com/rahulsprajapati/wp-local-docker.git <my-project-name>`
1. `cd <my-project-name>`
1. `docker-compose up -d`
1. Make ./dcwp.sh executable file.
	
	`chmod +x ./dcwp.sh`
1. Now we can use dcwp.sh script to create wp sites. Follow below command.


1. Create new site with WP Setup.
	
	./dcwp.sh {site_name} create/delete {root_password}
	
	example ./dcwp.sh test1.local create/delete
	```
	Note: if you want to add a entry to your /etc/hosts with this script then add 3rd arg for root password. This will be needed to write /etc/hosts file.
	```
2. ./dcwp.sh site list 
	This will list all the created sites.
3. Create new php empty site without any installation of WP.
	./dcwp.sh {site_name} createempty {root_password}

    example ./dcwp.sh test1.local create/delete


> You can create dcwp.sh as global command by creating a symlink to your user bin dir. ex. ln -s ./dcwp.sh /usr/bin/dcwp 

Default MySQL connection information (from within PHP-FPM container):

```
Database: wordpress
Username: wordpress
Password: password
Host: mysql
```

Default Elasticsearch connection information (from within PHP-FPM container):

```Host: http://elasticsearch:9200```

The Elasticsearch container is configured for a maximum heap size of 750MB to prevent out of memory crashes when using the default 2GB memory limit enforced by Docker for Mac and Docker for Windows installations or for Linux installations limited to less than 2GB. If you require additional memory for Elasticsearch override the value in a `docker-compose.override.yml` file as described below.

## Docker Compose Overrides File

Adding a `docker-compose.override.yml` file alongside the `docker-compose.yml` file, with contents similar to
the following, allows you to change the domain associated with the cluster while retaining the ability to pull in changes from the repo.

```
version: '3'
services:
  phpfpm:
    extra_hosts:
      - "dashboard.dev:172.18.0.1"
  elasticsearch:
    environment:
      ES_JAVA_OPTS: "-Xms2g -Xmx2g"
```

## WP-CLI

Add this alias to `~/.bash_profile` to easily run WP-CLI command.

```
alias dcwp='docker-compose exec --user www-data phpfpm wp'
```

Instead of running a command like `wp plugin install` you instead run `dcwp plugin install` from anywhere inside the
`<my-project-name>` directory, and it runs the command inside of the php container.

There is also a script in the `/bin` directory that will allow you to execute WP CLI from the project directory directly: `./bin/wp plugin install`.

## SSH Access

You can easily access the WordPress/PHP container with `docker-compose exec`. Here's a simple alias to add to your `~/.bash_profile`:

```
alias dcbash='docker-compose exec --user root phpfpm bash'
```

This alias lets you run `dcbash` to SSH into the PHP/WordPress container.

Alternatively, there is a script in the `/bin` directory that allows you to SSH in to the environment from the project directory directly: `./bin/ssh`.

## MailCatcher

MailCatcher runs a simple local SMTP server which catches any message sent to it, and displays it in it's built-in web interface. All emails sent by WordPress will be intercepted by MailCatcher. To view emails in the MailCatcher web interface, navigate to `http://localhost:1080` in your web browser of choice.

## Credits

This project is our own flavor of an environment created by John Bloch.
