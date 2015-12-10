#!/bin/bash -e

cd $BLIZKO_PATH

bash /sites/application/customize_dns.sh

### SERVICES ###

/usr/sbin/sshd
/usr/sbin/dnsmasq
service nginx start
service postgresql start
service memcached start
service redis_6379 start

### BACKGROUNDS & SPHINX ###

mkdir -p 'tmp/pids' # make path for god pid

script/bg_executor.rb start
rake sphinx:start resque:start denormalization:start

### UNICORN ###

# remove stale unicorn master pid (if exists) & run unicorn
rm -f /var/run/unicorn/unicorn.pid
unicorn -c config/unicorn.conf.rb -E production
