#!/bin/bash -e

cd $BLIZKO_PATH

bash /sites/application/customize_dns.sh

/usr/sbin/sshd
/usr/sbin/dnsmasq
service nginx start
service postgresql start
service memcached start
service redis-server start

RAILS_ENV=production rake ts:run
RAILS_ENV=production script/bg_executor.rb start
RAILS_ENV=production rake resque:start  denormalization:start

unicorn -c config/unicorn.conf.rb -E production
