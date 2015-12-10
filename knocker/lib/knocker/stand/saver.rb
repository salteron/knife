# coding: utf-8

require_relative 'tools/name_knockerizer'

module Knocker
  module Saver
    extend self

    def save(stand, env)
      NameKnockerizer.validate!(env)

      preserve(stand)
      stand.container.commit(env)
      restore(stand)
    end

    private

    def preserve(stand)
      # flush rt indexes to fs
      stand.connectors.sphinx.flush

      # commit redis db & soft shutdown
      stand.connectors.redis.stop
    end

    def restore(stand)
      stand.connectors.redis.start
    end
  end
end
