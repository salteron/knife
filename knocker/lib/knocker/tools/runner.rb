# -*- encoding : utf-8 -*-

require_relative 'logger'
require_relative 'informer'
require_relative '../docker/image'
require_relative 'nginx'

module Knocker
  class Runner
    def run_from_image(image_name, container_alias = nil)
      image = Image.new(image_name)

      check_image_existence(image)

      container = image.run(container_alias)

      Dockerfiler.generate_container_vhost(container)
      Nginx.reload

      Logger.log("#{container.url} (container name: #{container.name})")
    end

    def check_image_existence(image)
      if image.exists?
        Logger.log "image '#{image.name}' selected"
      else
        Logger.log_error "image '#{image.name}' doesn't exist"
      end
    end
  end
end
