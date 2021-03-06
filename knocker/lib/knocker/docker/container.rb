# -*- encoding : utf-8 -*-

require 'json'
require 'time'
require_relative 'image'

module Knocker
  class Container
    attr_reader :id

    CONTAINER_NAME_REGEXP = /\A#{Settings.application[:default_project]}.+\z/

    def initialize(id)
      @id = id
    end

    def inspection
      @inspection ||= JSON.parse(Docker.inspect(id)).first
    end

    def name
      inspection['Name'][1..-1]
    end

    def host_port_at(tcp_port)
      ports["#{tcp_port}/tcp"].first['HostPort']
    end

    def ports
      inspection['HostConfig']['PortBindings']
    end

    def sub_domain
      inspection['Config']['Env'].find { |e| e.match(/\ASUB_DOMAIN=/)}[11..-1]
    end

    def exists?
      Docker.exists?(id)
    end

    def image
      Image.new(image_name)
    end

    def image_name
      inspection['Config']['Image']
    end

    def running?
      inspection['State']['Running']
    end

    def vhost_name
      "#{name}_conf"
    end

    # in seconds
    def age
      Time.now - Time.parse(inspection['State']['StartedAt'])
    end

    def url
      "http://www.#{sub_domain}.#{Settings.www[:domain]}"
    end

    def commit(environment)
      Docker.commit(self, environment)
    end

    def self.find(container_name)
      unless Docker.exists?(container_name)
        fail "container with name #{container_name} doesn't exist"
      end

      container_id = JSON.parse(Docker.inspect(container_name)).first['ID']

      Container.new(container_id)
    end

    def self.all(running_only = true)
      containers = Docker.containers(CONTAINER_NAME_REGEXP)

      running_only ? containers.select(&:running?) : containers
    end
  end
end
