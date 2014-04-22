# -*- encoding : utf-8 -*-
require 'json'

module Knocker
  module DockerAdapter
    def self.build(image_name, build_dir)
      [
        `cd #{build_dir} && docker build -t #{image_name} .`,
        $?.success?
      ]
    end

    def self.run(image_name, container_name, sub_domain)
      cmd = 'docker run' \
            " -e DOMAIN=#{Settings.www[:domain]}" \
            " -e SUB_DOMAIN=#{sub_domain}" \
            " --name #{container_name} -d -P #{image_name}"

      [
        `#{cmd}`.strip,
        $?.success?
      ]
    end

    def self.commit(container_name, image_name)
      [
        `docker commit #{container_name} #{image_name}`,
        $?.success?
      ]
    end

    def self.inspect(img_or_container_name)
      `docker inspect #{img_or_container_name} 2> /dev/null`
    end

    def self.exists?(image_or_container_name)
      inspect(image_or_container_name)
      $?.success?
    end

    def self.containers_ids(name_regexp)
      JSON.parse(`docker ps -a -q | xargs -r docker inspect`)
        .select { |c| c['Name'][1..-1].match(name_regexp) }
        .map { |c| c['ID'] }
    end

    def self.remove_containers(ids)
      `docker rm -f #{ids.join(' ')}` unless ids.empty?
    end
  end
end
