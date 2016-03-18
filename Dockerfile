FROM      ubuntu
MAINTAINER Olexander Kutsenko <olexander.kutsenko@gmail.com>

#install SOFT
RUN apt-get update -y
RUN apt-get install -y software-properties-common python-software-properties
RUN apt-get install -y git git-core vim nano mc nginx screen curl unzip

#Install PHP7
RUN add-apt-repository -y ppa:ondrej/php && \
apt-get update && \
apt-get install php7.0 php7.0-cli php7.0-common php7.0-cgi php7.0-curl php7.0-imap php7.0-pgsql php7.0-sqlite3 php7.0-mysql php7.0-fpm php7.0-intl php7.0-gd php7.0-json php7.0-ldap php-memcached php-memcache php-imagick php7.0-xml php7.0-mbstring -y && \
sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.0/fpm/php.ini && \
sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.0/cgi/php.ini && \
sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.0/cli/php.ini && \
sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.0/fpm/php.ini && \
sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.0/cgi/php.ini && \
sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.0/cli/php.ini && \
echo "php_admin_value[upload_max_filesize] = 32M" >> /etc/php/7.0/fpm/pool.d/www.conf && \
echo "php_admin_value[post_max_size] = 32M" >> /etc/php/7.0/fpm/pool.d/www.conf && \
echo "php_flag[display_errors] = off" >> /etc/php/7.0/fpm/pool.d/www.conf && \
echo "php_admin_flag[log_errors] = on" >> /etc/php/7.0/fpm/pool.d/www.conf && \
echo "php_flag[expose_php] = Off" >> /etc/php/7.0/fpm/pool.d/www.conf && \
mkdir -p /run/php && \
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash - && \
apt-get install -y nodejs && \
ln -s /usr/bin/node /usr/local/bin/node

#MySQL install + password
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN sudo apt-get  install -y mysql-server mysql-client

# SSH service
RUN sudo apt-get install -y openssh-server openssh-client
RUN sudo mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
#change 'pass' to your secret password
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#configs bash start
COPY configs/autostart.sh /root/autostart.sh
RUN chmod +x /root/autostart.sh
COPY configs/bash.bashrc /etc/bash.bashrc

#ant install
RUN sudo apt-get install -y default-jre default-jdk
RUN sudo apt-get install -y ant

#Composer
RUN cd /home
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
RUN chmod 777 /usr/local/bin/composer

#Code standart
RUN composer global require "squizlabs/php_codesniffer=*"
RUN composer global require "sebastian/phpcpd=*"
RUN composer global require "phpmd/phpmd=@stable"
RUN cd /usr/bin && ln -s ~/.composer/vendor/bin/phpcpd
RUN cd /usr/bin && ln -s ~/.composer/vendor/bin/phpmd
RUN cd /usr/bin && ln -s ~/.composer/vendor/bin/phpcs

#aliases
RUN alias ll='ls -la'

#Add colorful command line
RUN echo "force_color_prompt=yes" >> .bashrc
RUN echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> .bashrc


#etcKeeper
RUN mkdir -p /root/etckeeper
COPY configs/etckeeper.sh /root
COPY configs/files/etckeeper-hook.sh /root/etckeeper
RUN /root/etckeeper.sh


#open ports
EXPOSE 80 22