# coding: utf-8

require 'fileutils'

module Knocker
  module DockerLogger
    extend self

    DOCKER_LOGS_DIR         = File.join(APP_ROOT, 'logs')

    def self.write_commit_log(container_name, commit_log)
      FileUtils.mkpath(DOCKER_LOGS_DIR) unless File.directory?(DOCKER_LOGS_DIR)

      File.write(File.join(DOCKER_LOGS_DIR, container_name), commit_log)
    end
  end
end
