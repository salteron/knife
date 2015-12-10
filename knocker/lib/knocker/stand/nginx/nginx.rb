# coding: utf-8

require 'fileutils'
require 'command'

module Knocker
  module Nginx
    extend self

    HOST_VHOST_TEMPLATE = File.join(Knocker::APP_ROOT, 'lib/knocker/stand/nginx/host_vhost_template')


    def add_route(stand)
      add_vhost(stand, vhost_name(stand))
    end

    def rm_route(stand)
      rm_vhost(vhost_name(stand))
    end

    private

    def vhost_name(stand)
      "#{stand.id}_conf"
    end

    def add_vhost(stand, vhost_name)
      vhost = File.join(Settings.nginx[:vhosts_dir], vhost_name)
      generate_stand_vhost(stand, vhost)

      reload
    end

    def rm_vhost(vhost_name)
      vhost = File.join(Settings.nginx[:vhosts_dir], vhost_name)
      FileUtils.rm_f(vhost)

      reload
    end

    def reload
      Command.run("#{Settings.nginx[:reload_cmd]}")
    end

    def generate_stand_vhost(stand, vhost)
      www_port = stand.container.external_port_at(Stand::INTERNAL_PORTS[:www])
      sub_domain = stand.sub_domain

      template = HOST_VHOST_TEMPLATE

      substitution = {
          port: www_port,
          sub_domain: sub_domain,
          domain: Settings.www[:domain],
          host_ip: Settings.docker[:host_ip]
      }

      Substitutor.sub(template, vhost, substitution)
    end
  end
end
