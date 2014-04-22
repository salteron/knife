# -*- encoding : utf-8 -*-

require_relative 'docker'
require_relative 'container'
require_relative '../tools/git'
require_relative '../tools/random_name_generator'

module Knocker
  class Image
    attr_accessor :project, :env, :branch, :tag, :parent_image, :inspection

    IMAGE_NAME_REGEXP = /
      \A
      (?<project>[^_]+)_
      (?<env>[^_]+)
      (_(?<branch>[^_:]+)
      (:(?<tag>\w+))?)?
      \z
    /x

    DEFAULT_TAG = 'latest'

    def initialize(name, parent_image = self)
      match_data = IMAGE_NAME_REGEXP.match(name)

      fail "invalid image name: #{name}" unless match_data

      @project = match_data[:project]
      @env     = match_data[:env]
      @branch  = match_data[:branch]
      @tag     = match_data[:tag] || DEFAULT_TAG

      @parent_image = parent_image
    end

    def name
      [repository, tag].join(':')
    end

    def repository
      [@project, @env, @branch].join('_')
    end

    # существует ли образ с заданным именем
    def exists?
      Docker.exists?(name)
    end

    def form_derivative_image(branch)
      new_image_repository = [@project, @env, branch].join('_')
      new_image_tag        = Git.last_commit_hash(@project, branch)
      new_image_name       = [new_image_repository, new_image_tag].join(':')

      Image.new(new_image_name, self)
    end

    # form and run container from self
    # Ex:
    #   Image.run
    #   # => new container with name blizko_base_develop_crazy-einstein, and
    #   # => http://www.crazy-einstein.develop.base.blizko.knf.railsc.ru
    #
    #   Image.run('red-carpet')
    #   # => new container with name blizko_base_develop_red-carpet, and
    #   # => http://www.red-carpet.knf.railsc.ru
    def run(container_alias = nil)
      uniq_word      = container_alias ? container_alias : RandomNameGenerator.generate

      container_name = [
        repository,
        uniq_word
      ].join('_')

      sub_domain = container_alias ? container_alias : container_name.split('_').reverse.join('.')

      Docker.run(self, container_name, sub_domain)
    end

    def ==(other)
      # return true if self is equal to other_object, false otherwise
      name == other.name
    end

    def rnd_alias_alt
      Time.now.to_i
    end

    #
    # class methods
    #

    def self.all(project)
      # -a         | все образы
      # --no-trunc | не обрезанные теги
      cmd = "docker images -a --no-trunc | tail -n+2 | sed 's/\s\s*/ /g' |" \
            " cut -d' ' -f1,2,3 | grep -E '^#{project}\\_'"
      lines = `#{cmd}`.split("\n")

      image_names = lines.map do |line|
        [line.split[0], line.split[1]].compact.join(':')
      end

      image_names.select { |image_name| image_name =~ IMAGE_NAME_REGEXP }
        .map { |image_name| Image.new(image_name) }
    end
  end
end
