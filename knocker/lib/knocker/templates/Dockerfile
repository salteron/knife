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

# preparing image (environment)
RUN /bin/bash -l -c "\
  /usr/sbin/dnsmasq &&\
  service postgresql start &&\
  service memcached start &&\
  service redis-server start &&\
  bundle install &&\
  rails db production <<< 'reindex table companies' &&\
  RAILS_ENV=production rake core:db:migrate sphinx:rebuild &&\
  rails db production <<< 'reindex table companies' &&\
  RAILS_ENV=production rake assets:precompile knife:prepare"

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

CMD /bin/bash -l -c "\
  bash /sites/application/customize_dns.sh &&\
  /usr/sbin/sshd    &&\
  /usr/sbin/dnsmasq &&\
  service nginx start &&\
  service postgresql start &&\
  service memcached start &&\
  service redis-server start &&\
  RAILS_ENV=production rake ts:run &&\
  RAILS_ENV=production script/bg_executor.rb start &&\
  RAILS_ENV=production rake resque:start  denormalization:start &&\
  unicorn -c config/unicorn.conf.rb -E production"
