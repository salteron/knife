# coding: utf-8

require_relative 'docker'
require_relative 'container'
require_relative '../../etc/git'
require_relative 'tools/random_name_generator'
require_relative '../../stand/tools/name_knockerizer'

module Knocker
  class Image
    attr_accessor :project, :env, :branch, :tag, :parent_image, :inspection

    IMAGE_NAME_REGEXP = /
      \A
      (?<project>#{Settings.application[:default_project]})_
      (?<env>[^_]+)
      (_(?<branch>[^_:]+)
      (:(?<tag>\w+))?)?
      \z
    /x

    DEFAULT_TAG = 'latest'
    BASE_ENV = 'base'
    BASE_BRANCH = 'develop'
    BASE_IMAGE_NAME = [
      Settings.application[:default_project],
      BASE_ENV,
      BASE_BRANCH
    ].join('_')

    def initialize(environment, branch, tag = nil)
      @project = Settings.application[:default_project]
      @env     = environment
      @branch  = branch
      @tag     = tag || Git.last_commit_hash(@branch)
    end

    def name
      [repository, tag].join(':')
    end

    def repository
      [@project, @env, NameKnockerizer.knockerize(@branch)].join('_')
    end

    # существует ли образ с заданным именем
    def exists?
      Image.exists?(name)
    end

    def build_from(build_dir)
      Docker.build(name, build_dir)
    end

    # form and run container from self
    # Ex:
    #   Image.run
    #   # => new container with name blizko_base_develop_crazy-einstein, and
    #   # => http://www.crazy-einstein.develop.base.blizko.knf.railsc.ru
    #
    #   Image.run('red-carpet')
    #   # => new container with name blizko_base_develop_red-carpet, and
    #   # => http://www.red-carpet.develop.base.blizko.knf.railsc.ru
    def run(container_alias = nil)
      uniq_word = if container_alias
                    container_alias
                  else
                    RandomNameGenerator.generate
                  end

      container_name = [
        repository,
        uniq_word
      ].join('_')

      sub_domain = container_name.split('_').reverse.join('.')

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

    def self.all
      Docker.images(IMAGE_NAME_REGEXP)
    end

    def self.find(name)
      match_data = IMAGE_NAME_REGEXP.match(name)

      fail "invalid image name: #{name}" unless match_data
      fail "image doesn't exists: #{name}" unless Image.exists?(name)

      env     = match_data[:env]
      branch  = match_data[:branch]
      tag     = match_data[:tag] || DEFAULT_TAG

      Image.new(env, branch, tag)
    end

    def self.exists?(name)
      Docker.exists?(name)
    end

    def self.base_image
      find(BASE_IMAGE_NAME)
    end
  end
end
