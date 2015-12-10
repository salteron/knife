# coding: utf-8

require_relative 'stand'
require_relative 'docker/image_builder'
require_relative 'docker/container_runner'
require_relative 'docker/container'
require_relative 'nginx/nginx'

module Knocker
  module Wizard
    extend self

    CONTAINER_NAME_REGEXP = /\A#{Settings.application[:default_project]}.+\z/

    def create(environment, branch, container_alias)
      image = ImageBuilder.build_from_env_and_branch(environment, branch)
      container = ContainerRunner.run_from_image(image.name, container_alias)

      stand = Stand.new(container)
      Nginx.add_route(stand)

      stand
    end

    def open(container_name)
      Stand.new(Container.find(container_name))
    end

    def all(running_only = true)
      containers(running_only).map { |c| Stand.new(c) }
    end

    private

    def containers(running_only = true)
      Container.all(CONTAINER_NAME_REGEXP, running_only)
    end
  end
end
