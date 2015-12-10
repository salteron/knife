# coding: utf-8

require 'forwardable'
require_relative 'connection/connectors'
require_relative 'cleaner'
require_relative 'saver'

module Knocker
  class Stand
    extend Forwardable

    INTERNAL_PORTS = {
        :www   => 80,
        :redis => 6379,
        :ssh   => 22
    }

    attr_reader :container, :connectors

    def_delegators :@container, :image, :running?, :age, :sub_domain, :url
    def_delegator  :@container, :name, :id

    def_delegators :@image, :project, :env, :branch
    def_delegator  :@image, :tag, :commit_hash

    def initialize(container)
      @container = container
      @connectors = Connectors.new(@container)
    end

    def save(as)
      Saver.save(self, as)
    end

    def delete
      Cleaner.clean(self)
    end

    def rake(task)
      connectors.rake_executor.knife_prepare
    end
  end
end
