# coding: utf-8

require_relative '../../../etc/logger'

module Knocker
  class Sphinx
    def initialize(ssh_connector)
      @ssh_connector = ssh_connector
    end

    def flush
      Logger.log('flushing sphinx indexes...')

      cmd = '. /etc/profile &&\
             cd $BLIZKO_PATH &&\
             bundle exec rake sphinx:rebuild RAILS_ENV=$RAILS_ENV'

      @ssh_connector.run_command(cmd)
    end
  end
end
