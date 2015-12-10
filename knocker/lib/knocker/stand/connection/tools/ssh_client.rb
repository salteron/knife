# coding: utf-8

require 'net/ssh'
require_relative '../../../etc/logger'

module Knocker
  class SshClient
    HOST = 'localhost'
    SSH_USER = 'root'
    SSH_PASS = 'root'

    def initialize(host, user, password, ssh_host_port)
      @host = host
      @user = user
      @password = password
      @ssh_host_port = ssh_host_port
    end

    def run_command(command)
      Net::SSH.start(@host, @user, :password => @password, :port => @ssh_host_port) do |ssh|
        puts ssh.exec!(command)
      end
    end
  end
end
