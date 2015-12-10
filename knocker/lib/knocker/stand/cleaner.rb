# coding: utf-8

require_relative 'wizard'
require_relative 'docker/docker'
require_relative 'nginx/nginx'
require_relative '../etc/logger'

module Knocker
  module Cleaner
    extend self

    RETIREMENT_AGE = 60 * 60 * 24 # a day

    def clean_all
      summon_mr_proper(Wizard.all(false))
    end

    def clean_stale
      summon_mr_proper(stale_stands)
    end

    def clean(stand)
      summon_mr_proper([stand])
    end

    private

    def summon_mr_proper(stands)
      return if stands.empty?

      Logger.log("stands to be removed: #{stands.map(&:id)}")

      Docker.remove_containers(stands.map(&:container))
      stands.each { |s| Nginx.rm_route(s) }

      Logger.log('done!')
    end

    def stale_stands
      stands = Wizard.all(false)

      not_running_stands = stands.reject(&:running?)
      old_stands = (stands - not_running_stands)
        .select { |s| s.age > RETIREMENT_AGE }

      not_running_stands + old_stands
    end
  end
end
