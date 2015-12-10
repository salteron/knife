# coding: utf-8

module Knocker
  module Informer
    extend self

    def list_images
      head = 'Available images'
      list = Image.all.map(&:name).join("\n")

      log_list(head, list)
    end

    def list_environments
      head = 'Available environments'
      list = Image.all.map(&:env).uniq.join("\n")

      log_list(head, list)
    end

    def list_branches(project = Settings.application[:default_project])
      head = 'Available branches'
      list = Git.branches(project).join("\n")

      log_list(head, list)
    end

    def list_containers
      head = 'Running containers'
      list = Wizard.all.map { |c| "#{c.id} (#{c.url})" }.join("\n")

      log_list(head, list)
    end

    private

    def log_list(head, list)
      Logger.log([head, list].join("\n") + "\n")
    end
  end
end
