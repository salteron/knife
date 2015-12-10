# coding: utf-8

require_relative '../../tools/substitutor'
require_relative '../../stand'

module Knocker
  module Dockerfiler
    extend self

    TEMPLATES_DIR           = File.join(Knocker::APP_ROOT,
                                        'lib/knocker/stand/docker/templates')

    DOCKERFILE_TEMPLATE     = File.join(TEMPLATES_DIR, 'Dockerfile')
    UPDATED_AT_TEMPLATE     = File.join(TEMPLATES_DIR, 'updated_at.txt')

    RUN_SCRIPT              = File.join(TEMPLATES_DIR, 'run.sh')

    # Generate dockerfile for an image from template
    # and put it to target dir
    def generate_dockerfile(parent_image_name, branch, target_dir)
      template = DOCKERFILE_TEMPLATE
      target   = File.join(target_dir, 'Dockerfile')

      substitution = {
        tag: parent_image_name,
        branch: branch
      }

      Substitutor.sub(template, target, substitution)

      target
    end

    # Generate updated_at.txt for an image from template
    # and put it to target dir
    def generate_updated_at_txt(image, target_dir)
      template = UPDATED_AT_TEMPLATE
      target   = File.join(target_dir, 'updated_at.txt')

      substitution = {
        project: image.project,
        env: image.env,
        branch: image.branch,
        tag: image.tag,
        image_name: image.name,
        time: Time.now.to_s
      }

      Substitutor.sub(template, target, substitution)

      target
    end

    def generate_run_script(target_dir)
      template = RUN_SCRIPT
      target   = File.join(target_dir, 'run.sh')

      Substitutor.sub(template, target, {}) # just copy as-is
    end
  end
end
