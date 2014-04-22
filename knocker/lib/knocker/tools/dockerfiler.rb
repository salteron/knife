# -*- encoding : utf-8 -*-

require_relative 'substitutor'

module Knocker
  module Dockerfiler
    extend self

    TEMPLATES_DIR           = File.join(::Knocker::APP_ROOT,
                                        'lib/knocker/templates')

    DOCKERFILE_TEMPLATE     = File.join(TEMPLATES_DIR, 'Dockerfile')
    UPDATED_AT_TEMPLATE     = File.join(TEMPLATES_DIR, 'updated_at.txt')

    # идет на х*ст
    HOST_VHOST_TEMPLATE     = File.join(TEMPLATES_DIR, 'host_vhost_template')

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

    def generate_container_vhost(container)
      template = HOST_VHOST_TEMPLATE
      target   = File.join(Settings.nginx[:vhosts_dir],
                           "#{container.name}_conf")

      substitution = {
        port: container.host_port_at(80),
        sub_domain: container.domain,
        domain: Settings.www[:domain],
        host_ip: Settings.docker[:host_ip]
      }

      Substitutor.sub(template, target, substitution)
    end

    def self.generate_run_script(target_dir)
      template = RUN_SCRIPT
      target   = File.join(target_dir, 'run.sh')

      Substitutor.sub(template, target, {}) # just copy as-is
    end
  end
end
