FROM %tag%

MAINTAINER Michael Sogomonyan ms.sogomonyan@gmail.com

ENV BLIZKO_PATH       /sites/application/blizko
ENV RAILS_ENV         production

USER root
WORKDIR /sites/application/blizko

# =========================================================================
# параметризуем собранный образ
# =========================================================================

# информация об окружении и версии кода приложения
ADD updated_at.txt $BLIZKO_PATH/public/system/updated_at.txt

# скрипт кастомизации доменных имен, отрабатывающий во время
# запуска контейнера (hotfix)
# ADD customize_dns.sh /sites/application/customize_dns.sh

# =========================================================================
# конфиги
# =========================================================================

RUN /bin/bash -l -c "\
  git checkout . && git pull && git checkout %branch% &&\
  cp -r $BLIZKO_PATH/packages/blizko/knife/defaults/config/* $BLIZKO_PATH/config &&\
  cp $BLIZKO_PATH/config/hosts.rb $BLIZKO_PATH/config/hosts.rb.sample"

ADD unicorn.conf.rb $BLIZKO_PATH/config/unicorn.conf.rb
ADD production.rb   $BLIZKO_PATH/config/environments/production.rb

# =========================================================================
# создаем окружение
# =========================================================================

RUN /bin/bash -l -c "\
  /usr/sbin/dnsmasq &&\
  service postgresql start &&\
  service memcached start &&\
  service redis_6379 start &&\
  bundle install --without=development &&\
  RAILS_ENV=production rake core:db:migrate sphinx:rebuild &&\
  RAILS_ENV=production rake assets:precompile knife:prepare &&\
  redis-cli save &&\
  service postgresql stop &&\
  service redis_6379 stop"

# =========================================================================
# expose
# =========================================================================

# nginx
EXPOSE 80

# unicorn
EXPOSE 8887

# ssh
EXPOSE 22

# memcached
EXPOSE 11211

# redis
EXPOSE 6379

# PostgreSQL
EXPOSE 5432

# dnsmasq
EXPOSE 5353/udp

# =========================================================================
# entrypoint
# =========================================================================

ADD run.sh /sites/application/run.sh
CMD /bin/bash -l /sites/application/run.sh
