# coding: utf-8

require_relative '../../../etc/logger'

module Knocker
  class RakeExecutor
    def initialize(ssh_connector)
      @ssh_connector = ssh_connector
    end

    def knife_prepare
      rake('knife:prepare')
    end

    private

    def rake(task)
      Logger.log("executing rake #{task}")

      cmd = ". /etc/profile &&\
             cd $BLIZKO_PATH &&\
             bundle exec rake #{task} RAILS_ENV=$RAILS_ENV"

      @ssh_connector.run_command(cmd)
    end
  end
end
