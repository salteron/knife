# coding: utf-8

require 'json'
require 'command'

module Knocker
  module DockerAdapter
    extend self

    def build(image_name, build_dir)
      Command.run("cd #{build_dir} && docker build -t #{image_name} . 2>&1")
    end

    def run(image_name, container_name, sub_domain)
      text = 'docker run' \
             " -e DOMAIN=#{Settings.www[:domain]}" \
             " -e SUB_DOMAIN=#{sub_domain}" \
             " --name #{container_name} -d -P #{image_name}"

      Command.run(text)
    end

    def commit(container_name, image_name)
      Command.run("docker commit #{container_name} #{image_name}")
    end

    def inspect(img_or_container_name)
      Command.run("docker inspect #{img_or_container_name}").stdout
    end

    def exists?(img_or_container_name)
      Command.run("docker inspect #{img_or_container_name}").success?
    end

    def containers_ids(name_regexp)
      inspection = Command.run('docker ps -a -q | xargs -r docker inspect').stdout
      return [] if inspection.empty?

      JSON.parse(inspection)
        .select { |c| c['Name'][1..-1].match(name_regexp) }
        .map { |c| c['ID'] }
    end

    def remove_containers(ids)
      Command.run("docker rm -f #{ids.join(' ')}") unless ids.empty?
    end

    def images_names(name_regexp)
      names = Command.run("docker images -a --no-trunc \
                           | tail -n+2 | sed 's/\s\s*/ /g' \
                           | cut -d' ' -f1,2 \
                           | sed 's/\s/:/g'").stdout.split

      names.select { |name| name.match(name_regexp) }
    end
  end
end
