#!/bin/bash
service php7.0-fpm start
service nginx start
service ssh start
service mysql start
service memcached start
service supervisor start