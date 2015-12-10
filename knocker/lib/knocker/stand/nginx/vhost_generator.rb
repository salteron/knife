# coding: utf-8

require_relative 'substitutor'
require_relative '../stand'

module Knocker
  module VhostGenerator
    extend self

    HOST_VHOST_TEMPLATE = File.join(Knocker::APP_ROOT, 'lib/knocker/stand/connection/nginx/host_vhost_template')

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
