#!/bin/bash -e

###
### Cкрипт, кастомизирубющий доменное имя запускаемого контейнера
###
###   - в качестве шаблона используются vhosts и hosts.rb,
###     взятые с knife.rails.ru и содержащиеся в базовом образе;
###
###   - параметром выступает переменная окружения SUB_DOMAIN и DOMAIN указываемые команде
###     `docker run` во время запуска контейнера.
###

# TODO: переменные должны передаваться команде запуска контейнера
VHOSTS_TEMPLATES_PATH='/etc/nginx/vhosts_templates'
VHOSTS_PATH='/etc/nginx/vhosts'
HOSTS_RB_SAMPLE='/sites/application/blizko/config/hosts.rb.sample'
HOSTS_RB='/sites/application/blizko/config/hosts.rb'
DNSMASQ_CONF_SAMPLE='/etc/dnsmasq.conf.sample'
DNSMASQ_CONF='/etc/dnsmasq.conf'

### кастомизируем nginx vhosts ###

cp ${VHOSTS_TEMPLATES_PATH}/* ${VHOSTS_PATH}

sed -i "s/knife.railsc.ru/${SUB_DOMAIN}.${DOMAIN}/g" ${VHOSTS_PATH}/*_conf
sed -i 's/\/home\/blizko\/current\/public/\/sites\/application\/blizko\/public/g' ${VHOSTS_PATH}/*_conf
sed -i 's/\/home\/blizko\/static/\/sites\/application\/static/g' ${VHOSTS_PATH}/*_conf

sed -i "s/\\.knife\\.railsc\\.ru/\\.${SUB_DOMAIN}\\.${DOMAIN}/g" ${VHOSTS_PATH}/*_conf

### кастомизируем hosts.rb ###
sed -e "s/knife.railsc.ru/${SUB_DOMAIN}.${DOMAIN}/g" ${HOSTS_RB_SAMPLE} > ${HOSTS_RB}

### кастомизируем dnsmasq.conf ###
sed -e "s/knife\\.railsc\\.ru/${DOMAIN}/g" ${DNSMASQ_CONF_SAMPLE} > ${DNSMASQ_CONF}
