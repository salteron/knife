# coding: utf-8

require 'yaml'
require_relative 'deep_symbolize'

module Knocker
  module Settings
    # again - it's a singleton, thus implemented as a self-extended module
    extend self

    @_settings = {}
    attr_reader :_settings

    # This is the main point of entry - we call Settings.load! and provide
    # a name of the file to read as it's argument. We can also pass in some
    # options, but at the moment it's being used to allow per-environment
    # overrides in Rails
    def load!(filename)
      @_settings = YAML::load_file(filename).deep_symbolize
    end

    def method_missing(name, *args, &block)
      @_settings[name.to_sym] ||
          fail(NoMethodError, "unknown configuration root #{name}", caller)
    end
  end

  class ::Hash; include DeepSymbolizable; end
end
