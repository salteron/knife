# coding: utf-8

require_relative 'docker_adapter'
require_relative 'container'
require_relative 'tools/docker_logger'
require_relative '../../etc/logger'

module Knocker
  class Docker
    def self.build(image_name, build_dir)
      Logger.log "building image #{image_name} ..."
      command = DockerAdapter.build(image_name,
                                    build_dir)

      File.write(File.join(build_dir, 'build.log'), command.stdout)

      unless command.success?
        fail "error while building image #{image_name}:" \
             'see docker logs for details'
      end
    end

    # returns new running container
    def self.run(image, container_name, sub_domain)
      Logger.log "running container from #{image.name} ..."

      command = DockerAdapter.run(image.name,
                                  container_name,
                                  sub_domain)
      fail command.stderr unless command.success?

      Container.new(command.stdout.strip)
    end

    def self.commit(container, environment)
      Logger.log "committing container '#{container.name}' ..."

      new_image     = container.image.dup
      new_image.env = environment

      command = DockerAdapter.commit(container.name,
                                     new_image.name)

      DockerLogger.write_commit_log(container.name, command.stdout)
      unless command.success?
        fail "error while committing container '#{container.name}'" \
             " to an image '#{new_image.name}':\n#{command.stdout}"
      end
    end

    def self.inspect(name_or_id)
      DockerAdapter.inspect(name_or_id)
    end

    def self.exists?(name_or_id)
      DockerAdapter.exists?(name_or_id)
    end

    def self.containers(name_regexp)
      DockerAdapter.containers_ids(name_regexp).map { |id| Container.new(id) }
    end

    def self.remove_containers(containers)
      DockerAdapter.remove_containers(containers.map(&:id))
    end

    def self.images(name_regexp)
      DockerAdapter.images_names(name_regexp).map { |name| Image.find(name) }
    end
  end
end
