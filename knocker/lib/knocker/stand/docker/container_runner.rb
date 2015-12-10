# coding: utf-8

require_relative 'image'
require_relative '../tools/name_knockerizer'

module Knocker
  module ContainerRunner
    extend self

    def run_from_image(image_name, container_alias = nil)
      image = Image.find(image_name)

      if container_alias
        NameKnockerizer.validate!(container_alias)

        container = Stand.containers.find do |c|
          c.image_name == image.name && c.alias == container_alias
        end

        return container if container
      end

      image.run(container_alias)
    end
  end
end
