# -*- encoding : utf-8 -*-

require_relative 'docker_adapter'
require_relative 'container'
require_relative '../tools/dockerfiler'
require_relative '../tools/logger'
require_relative '../tools/docker_logger'

require 'fileutils'
require 'json'

module Knocker
  class Docker
    BUILDS_DIR          = File.join(APP_ROOT, 'building_area')
    HOT_FILES           = File.join(BUILDS_DIR, 'hot_files/*')

    def self.build(image)
      build_dir         = prepare_build_dir(image)
      target_image_name = image.name

      Logger.log "building image #{target_image_name} ..."
      build_log, success = DockerAdapter.build(target_image_name,
                                                   build_dir)

      File.write(File.join(build_dir, 'build.log'), build_log)

      unless success
        fail "error while building image #{target_image_name}:" \
             'see docker logs for details'
      end

      # File.delete(updated_at, dockerfile)
    end

    # returns new running container
    def self.run(image, container_name, sub_domain)
      container_id, success = DockerAdapter.run(image.name,
                                                    container_name,
                                                    sub_domain)
      fail unless success

      Container.new(container_id, sub_domain)
    end

    def self.commit(container, environment)
      new_image     = container.image.dup
      new_image.env = environment

      commit_log, success = DockerAdapter.commit(container.name,
                                                     new_image.name)

      DockerLogger.write_commit_log(container.name, commit_log)
      unless success
        fail "error while committing container '#{container.name}'" \
             " to an image '#{new_image.name}':\n#{commit_log}"
      end
    end

    def self.inspect(name_or_id)
      DockerAdapter.inspect(name_or_id)
    end

    def self.exists?(name_or_id)
      DockerAdapter.exists?(name_or_id)
    end

    def self.prepare_build_dir(image)
      build_dir = File.join(BUILDS_DIR, Time.now.strftime('%FT%T') +
                                        '[' + image.name + ']')

      FileUtils.mkpath(build_dir)
      FileUtils.cp_r(Dir[HOT_FILES], build_dir)

      Dockerfiler.generate_updated_at_txt(image, build_dir)
      Dockerfiler.generate_dockerfile(image.parent_image.name,
                                      image.branch,
                                      build_dir)
      Dockerfiler.generate_run_script(build_dir)

      build_dir
    end
  end
end
