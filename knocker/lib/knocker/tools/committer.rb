# -*- encoding : utf-8 -*-

require_relative 'logger'
require_relative 'informer'
require_relative '../docker/image'
require_relative '../docker/docker'

module Knocker
  class Committer
    def commit_container_to_image(container_name, env)
      container = Container.find(container_name)
      container.commit(env)
    end
  end
end
