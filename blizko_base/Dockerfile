###       ###
### knife ###
###       ###

# =========================================================================
# ubuntu
# =========================================================================

# use the ubuntu base image provided by dotCloud (12.04)
FROM ubuntu

MAINTAINER Michael Sogomonyan ms.sogomonyan@gmail.com

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise-updates main restricted" >> /etc/apt/sources.list

RUN apt-get update

# =========================================================================
# environment variables
# =========================================================================

ENV BLIZKO_PATH       /sites/application/blizko
ENV RAILS_ENV         production

# =========================================================================
# SSH (root)
# =========================================================================

RUN apt-get install -y whois

# .ssh
RUN mkdir -p /root/.ssh/
ADD id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa

RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd

# change root passport
RUN echo 'root:root' |chpasswd

# =========================================================================
# memcached
# =========================================================================

# install memcached
RUN apt-get install -y memcached

# =========================================================================
# redis
# =========================================================================

# install redis server
# RUN apt-get install -y software-properties-common python-software-properties
# 2.6.13
# RUN add-apt-repository -y ppa:chris-lea/redis-server
# RUN apt-get update
RUN apt-get install -y redis-server

# =========================================================================
# rvm + ruby
# =========================================================================

RUN apt-get install -y curl

# installing rvm # using [sudo] to make rvm available to all users
RUN \curl -sSL https://get.rvm.io | sudo bash

RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc
RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install ruby-1.9.3-p374 && rvm use ruby-1.9.3-p374 --default'
RUN /bin/bash -l -c 'rvm rubygems current'

RUN /bin/bash -l -c "gem install bundler"

# =========================================================================
# postgresql
# =========================================================================

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.2``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update the Ubuntu and PostgreSQL repository indexes
RUN apt-get update

# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.2
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get -y -q install python-software-properties software-properties-common
RUN apt-get -y -q install postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2

# pl-perl; skytools (blizko)
RUN apt-get -y -q install postgresql-plperl-9.2 skytools-modules-9.2

# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.2`` package when it was ``apt-get installed``
USER postgres

# Меняем кодировку шаблона бд на UTF8
# Пришлось прописать USER=postgres, т.к. почему-то переключение пред. командой не происходит
RUN   USER=postgres /etc/init.d/postgresql start &&\
      psql --command "UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';" &&\
      psql --command "DROP DATABASE template1;" &&\
      psql --command "CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';" &&\
      psql --command "UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';" &&\
      psql --command "\c template1" &&\
      psql --command "VACUUM FREEZE;"

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.2/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.2/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.2/main/postgresql.conf

# Add VOLUMEs to allow backup of config, logs and databases
# VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER root

# =========================================================================
# sphinx 2.1.6
# =========================================================================

# install required packages
RUN apt-get -y install mysql-client unixodbc libpq5

# transfer sphinx package
RUN mkdir -p /home/root/install/
ADD sphinxsearch_2.1.6.deb /home/root/install/sphinxsearch_2.1.6.deb

# install sphinx
RUN dpkg -i /home/root/install/sphinxsearch_2.1.6.deb

# =========================================================================
# git & code
# =========================================================================

RUN apt-get install -y wget git-core

# Не задавать кодовый вопрос (?)
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# prevent “early EOF fatal error”
RUN git config --global core.compression -1

# RUN mkdir -p /sites/application/
RUN git clone git@github.com:abak-press/blizko.git $BLIZKO_PATH

# =========================================================================
# gems (bundle install)
# =========================================================================

RUN apt-get -y -q install libpq-dev libidn11-dev libmagickwand-dev libxslt-dev libxml2-dev catdoc enca libmysql-ruby libmysqlclient-dev libcurl3 libcurl3-gnutls libcurl4-openssl-dev

# change current dir
# WORKDIR $BLIZKO_PATH
# ENV не работает
WORKDIR /sites/application/blizko

# install gems
RUN /bin/bash -l -c "bundle install"

# =========================================================================
# configs
# =========================================================================

RUN cp -r $BLIZKO_PATH/packages/blizko/knife/defaults/config/* $BLIZKO_PATH/config

#ADD config/database.yml           $BLIZKO_PATH/config/database.yml
#ADD config/config.local.yml       $BLIZKO_PATH/config/config.local.yml
#ADD config/redis.yml              $BLIZKO_PATH/config/redis.yml
#ADD config/memcache.yml           $BLIZKO_PATH/config/memcache.yml
#ADD config/memcache.local.yml     $BLIZKO_PATH/config/memcache.local.yml
#ADD config/hosts.rb               $BLIZKO_PATH/config/hosts.rb.sample
#ADD config/sphinx.yml             $BLIZKO_PATH/config/sphinx.yml

#ADD config/bg_executor.yml        $BLIZKO_PATH/config/bg_executor.yml
#ADD config/resque.local.yml       $BLIZKO_PATH/config/resque.local.yml

#ADD config/environments/$RAILS_ENV.rb $BLIZKO_PATH/config/environments/$RAILS_ENV.rb

#ADD config/unicorn.conf.rb       $BLIZKO_PATH/config/unicorn.conf.rb

# =========================================================================
# dns-masq
# =========================================================================

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes dnsmasq-base dnsutils
ADD dnsmasq.conf /etc/dnsmasq.conf
ADD dnsmasq.conf /etc/dnsmasq.conf.sample
ADD resolv.dnsmasq.conf /etc/resolv.dnsmasq.conf

# скрипт кастомизации доменных имен, отрабатывающий во время
# запуска контейнера
ADD customize_dns.sh /sites/application/customize_dns.sh

# =========================================================================
# data
# =========================================================================

# set postgresql authentication (config dependent)
RUN echo 'localhost:5432:*:blizko:blizko' >> /root/.pgpass
RUN chmod 600 /root/.pgpass

# make dir for sphinx indexes
RUN mkdir -p $BLIZKO_PATH/db/sphinx/$RAILS_ENV

# create user blizko
#RUN sed -i 's/local   all             postgres                                peer/local all postgres md5/g' /etc/postgresql/9.2/main/pg_hba.conf
RUN service postgresql start && sudo -u postgres psql --command "CREATE USER blizko WITH SUPERUSER PASSWORD 'blizko';"

# psql knife.sql
RUN /bin/bash -l -c "service postgresql   start &&\
                     service redis-server start &&\
                     service memcached start &&\
                     rake db:create &&\
                     rails db $RAILS_ENV < db/knife.sql"


# =========================================================================
# unicorn
# =========================================================================

# place for pid
RUN mkdir -p /var/run/unicorn

# =========================================================================
# nginx
# =========================================================================

RUN apt-get -y install nginx

# конфиг nginx и др.файлы, общие для всех ножей
ADD config/nginx /etc/nginx
RUN mkdir -p /etc/nginx/vhosts

RUN mkdir -p /sites/application/static
