FROM cristo/symfony2
MAINTAINER Olexander Vdovychenko <farmazin@gmail.com>

#UPDATE PHP
RUN sudo apt-get install -y language-pack-en-base
RUN sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get install php7.0-fpm php7.0-cli -y
RUN apt-get install php7.0-mysql -y

#UPDATE NGINX CONF
RUN rm /etc/nginx/sites-available/default
COPY configs/nginx/default /etc/nginx/sites-available/default

#Autostart
RUN rm /root/autostart.sh
COPY configs/autostart.sh /root/autostart.sh
RUN chmod +x /root/autostart.sh

#OPEN PORT
EXPOSE 80 22