# -*- encoding : utf-8 -*-

module Knocker
  module Informer
    extend self

    def list_images(project = Settings.application[:default_project])
      head = 'Available images'
      list = Image.all(project).map(&:name).join("\n")

      log_list(head, list)
    end

    def list_branches(project = Settings.application[:default_project])
      head = 'Available branches'
      list = Git.branches(project).join("\n")

      log_list(head, list)
    end

    def list_containers(project = Settings.application[:default_project])
      head = 'Running containers'
      list = Container.all.map(&:name).join("\n")

      log_list(head, list)
    end

    private

    def log_list(head, list)
      Logger.log([head, list].join("\n"))
    end
  end
end
