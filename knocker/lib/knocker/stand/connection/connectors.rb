# coding: utf-8

require_relative 'tools/ssh_client'
require_relative 'connectors/redis'
require_relative 'connectors/sphinx'
require_relative 'connectors/rake_executor'

module Knocker
  class Connectors
    SSH_HOST = 'localhost'
    SSH_USER = 'root'
    SSH_PASS = 'root'

    attr_reader :redis, :sphinx, :rake_executor

    def initialize(container)
      ssh_port = container.external_port_at(Stand::INTERNAL_PORTS[:ssh])

      ssh_client = SshClient.new(SSH_HOST, SSH_USER, SSH_PASS, ssh_port)

      @redis = Redis.new(ssh_client)
      @sphinx = Sphinx.new(ssh_client)
      @rake_executor = RakeExecutor.new(ssh_client)
    end
  end
end
