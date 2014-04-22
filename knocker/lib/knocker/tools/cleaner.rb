# -*- encoding : utf-8 -*-

module Knocker
  module Cleaner
    extend self

    def clean_all
      containers             = Container.all(false)
      not_running_containers = containers.reject(&:running?)

      # living a day or longer
      day = 60 * 60 * 24
      old_containers         = (containers - not_running_containers)
                                 .select { |c| c.age > day }

      summon_mr_proper(not_running_containers + old_containers)
    end

    def clean(container_name)
      container = Container.find(container_name)

      summon_mr_proper([container])
    end

    private

    def summon_mr_proper(containers)
      return if containers.empty?

      Logger.log("containers to be removed: #{containers.map(&:name)}")

      Docker.remove_containers(containers)
      Nginx.rm_vhosts(containers.map(&:vhost_name))

      Logger.log('done!')
    end
  end
end
