# -*- encoding : utf-8 -*-

require_relative '../docker/docker'
require_relative '../docker/image'
require_relative 'git'
require_relative 'logger'
require_relative 'informer'

module Knocker
  class Builder
    def build_from_image_and_branch(parent_image_name, branch)
      parent_image = Image.new(parent_image_name)

      check_image_existence(parent_image)
      check_branch_existence(parent_image.project, branch)

      image = parent_image.form_derivative_image(branch)

      Docker.build(image) unless image.exists?

      image.name
    end

    private

    def check_image_existence(image)
      if image.exists?
        Logger.log "image '#{image.name}' selected"
      else
        Logger.log_error "image '#{image.name}' doesn't exist"
      end
    end

    def check_branch_existence(project, code_branch)
      if Git.branch_exists?(project, code_branch)
        Logger.log "branch '#{code_branch}' selected"
      else
        Logger.log_error "branch '#{code_branch}' doesn't exist"
      end
    end
  end
end
