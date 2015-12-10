# coding: utf-8

require_relative '../../../etc/logger'

module Knocker
  class Redis
    attr_reader :ssh_connector

    def initialize(ssh_connector)
      @ssh_connector = ssh_connector
    end

    def flush
      Logger.log('flushing redis data...')

      @ssh_connector.run_command('redis-cli save')
    end

    def start
      Logger.log('starting redis-server...')

      @ssh_connector.run_command('service redis_6379 start')
    end

    def stop
      Logger.log('shuting down redis-server...')

      @ssh_connector.run_command('service redis_6379 stop')
    end
  end
end
