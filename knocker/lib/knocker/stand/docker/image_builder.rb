# coding: utf-8

require 'fileutils'
require_relative 'image'
require_relative 'tools/dockerfiler'
require_relative '../../etc/git'
require_relative '../../etc/logger'

module Knocker
  module ImageBuilder
    extend self

    BUILDS_DIR = File.join(APP_ROOT, 'building_area')
    HOT_FILES  = File.join(BUILDS_DIR, 'hot_files/*')

    def build_from_env_and_branch(environment, branch)
      Git.validate!(branch)

      image = Image.new(environment, branch)

      unless image.exists?
        parent_image = elect_parent(environment, branch)
        build_dir = prepare_build_dir(image, parent_image)

        image.build_from(build_dir)
      end

      image
    end

    def build_from_image_and_branch(parent_image_name, branch)
      Git.validate!(branch)

      parent_image = Image.find(parent_image_name)
      image = Image.new(parent_image.env, branch)
      build_dir = prepare_build_dir(image, parent_image)

      image.build_from(build_dir) unless image.exists?

      image
    end

    private

    def elect_parent(environment, branch)
      case environment
      when 'base'
        # select base image
        Image.base_image
      else
        candidates = Image.all.select { |i| i.env == environment }

        if candidates.size.zero?
          fail "there are no images with environment '#{environment}'"
        end

        # select recent image, with the same branch preferably
        # (docker forms list of images with 'created_at desc' order)
        candidates.find { |i| i.branch == branch } || candidates.first
      end
    end

    def prepare_build_dir(image, parent_image)
      build_dir = File.join(BUILDS_DIR, Time.now.strftime('%FT%T') +
          '[' + image.name + ']')

      FileUtils.mkpath(build_dir)
      FileUtils.cp_r(Dir[HOT_FILES], build_dir)

      Dockerfiler.generate_updated_at_txt(image, build_dir)
      Dockerfiler.generate_dockerfile(parent_image.name,
                                      image.branch,
                                      build_dir)
      Dockerfiler.generate_run_script(build_dir)

      build_dir
    end
  end
end
