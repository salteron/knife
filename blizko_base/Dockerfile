###       ###
### knife ###
###       ###

# =========================================================================
# ubuntu
# =========================================================================

# use the ubuntu base image provided by dotCloud (12.04)
FROM ubuntu:precise

MAINTAINER Michael Sogomonyan ms.sogomonyan@gmail.com

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y upgrade

# =========================================================================
# environment variables
# =========================================================================

ENV DEBIAN_FRONTEND   noninteractive
ENV BLIZKO_PATH       /sites/application/blizko
ENV RAILS_ENV         production

# =========================================================================
# SSH (root)
# =========================================================================

# 1) добавляем ssh-key с доступом к репозиториям abak-press
# 2) change root passport для доступа к контейнеру по ssh

ADD id_rsa /root/.ssh/id_rsa

RUN /bin/bash -c "\
  apt-get install -y whois &&\
  chmod 700 /root/.ssh/id_rsa &&\
  apt-get install -y openssh-server &&\
  mkdir -p /var/run/sshd &&\
  echo 'root:root' |chpasswd"

# is automatically read when interactive shell (interactive ssh)
# is read manually when non-interactive
RUN echo "export BLIZKO_PATH=$BLIZKO_PATH" >> /etc/profile &&\
    echo "export RAILS_ENV=$RAILS_ENV" >> /etc/profile

# =========================================================================
# git + memcached + redis
# =========================================================================

RUN apt-get install -y wget git-core memcached

RUN git clone -b 2.6 https://github.com/antirez/redis.git &&\
    apt-get install -y -q build-essential tcl &&\
    cd redis && make && make install &&\
    cd utils && ./install_server.sh

# =========================================================================
# rvm + ruby
# =========================================================================

RUN apt-get install -y curl && curl -L https://get.rvm.io | bash -s stable

RUN /bin/bash -l -c "\
  echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc &&\
  echo 'export RUBY_HEAP_MIN_SLOTS=600000' >> /etc/rvmrc &&\
  echo 'export RUBY_GC_MALLOC_LIMIT=59000000' >> /etc/rvmrc &&\
  rvm requirements &&\
  rvm install ruby-1.9.3-p374 --patch railsexpress &&\
  rvm use ruby-1.9.3-p374 --default &&\
  rvm rubygems current &&\
  gem install bundler &&\
  bundle config --global jobs `nproc`"

# =========================================================================
# postgresql
# =========================================================================

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update

RUN apt-get -y -q install --force-yes perl-modules=5.14.2-6ubuntu2.4 perl=5.14.2-6ubuntu2.4 perl-base=5.14.2-6ubuntu2.4 libperl5.14

RUN apt-get -y -q install python-software-properties software-properties-common
RUN apt-get -y -q install postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2 postgresql-plperl-9.2 postgresql-9.2-pgq3

# ensure system UTF-8 and re-create cluster with new locale
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV LANGUAGE   en

RUN pg_dropcluster --stop 9.2 main
RUN pg_createcluster --locale en_US.utf-8 --start 9.2 main

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.

RUN echo "host all all ::1/128 trust" > /etc/postgresql/9.2/main/pg_hba.conf &&\
    echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/9.2/main/pg_hba.conf &&\
    echo "local all all trust" >> /etc/postgresql/9.2/main/pg_hba.conf &&\
    echo "listen_addresses='*'" >> /etc/postgresql/9.2/main/postgresql.conf &&\
    echo "ssl=false" >> /etc/postgresql/9.2/main/postgresql.conf

RUN service postgresql start &&\
    psql -U postgres -c "CREATE USER blizko WITH SUPERUSER PASSWORD 'blizko';" &&\
    service postgresql stop

# =========================================================================
# sphinx 2.1.6
# =========================================================================

# 1) transfer sphinx package
ADD sphinxsearch_2.1.6.deb /home/root/install/sphinxsearch_2.1.6.deb

# 2) install required packages and sphinx
RUN /bin/bash -c "\
  apt-get -y install mysql-client unixodbc libpq5 &&\
  dpkg -i /home/root/install/sphinxsearch_2.1.6.deb"

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

# 1) change current dir (WORKDIR $BLIZKO_PATH не работает)
WORKDIR /sites/application/blizko

# 2) install deps and gems
RUN /bin/bash -l -c "\
  apt-get -y -q install libpq-dev libidn11-dev libmagickwand-dev libxslt-dev libxml2-dev catdoc enca libmysql-ruby libmysqlclient-dev libcurl3 libcurl3-gnutls libcurl4-openssl-dev libmagickwand-dev imagemagick &&\
  bundle install --without=development"

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
ADD config/dns/dnsmasq.conf /etc/dnsmasq.conf
ADD config/dns/dnsmasq.conf /etc/dnsmasq.conf.sample
ADD config/dns/resolv.dnsmasq.conf /etc/resolv.dnsmasq.conf

# скрипт кастомизации доменных имен, отрабатывающий во время
# запуска контейнера
ADD customize_dns.sh /sites/application/customize_dns.sh

# =========================================================================
# data
# =========================================================================

# 1) set postgresql authentication (config dependent)
# 2) make dir for sphinx indexes
# 3) create user blizko
# 4) load dump

RUN /bin/bash -l -c "\
    mkdir -p $BLIZKO_PATH/db/sphinx/$RAILS_ENV &&\
    service postgresql start &&\
    service redis_6379 start &&\
    service memcached start &&\
    RAILS_ENV=$RAILS_ENV rake db:create  &&\
    rails db $RAILS_ENV < db/knife.sql &&\
    service postgresql stop && \
    service redis_6379 stop"

# =========================================================================
# nginx
# =========================================================================

RUN apt-get -y install nginx

# конфиг nginx
ADD config/nginx /etc/nginx

# =========================================================================
# unicorn & nginx specific dirs
# =========================================================================

# 1) place for unicorn pid
# 2) place for vhosts
# 3) place for static
RUN mkdir -p /var/run/unicorn /etc/nginx/vhosts /sites/application/static

# =========================================================================
# required files
# =========================================================================

# добавляем заглушки для корректной работы Resque::ProcessProductImageJob

RUN mkdir -p $BLIZKO_PATH/public/system/images/product &&\
    cp $BLIZKO_PATH/public/images/products/stub_* $BLIZKO_PATH/public/system/images/product
