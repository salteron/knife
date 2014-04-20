# -*- encoding : utf-8 -*-

require_relative 'knocker/tools/settings'
require 'fileutils'

module Knocker
  APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  Settings.load!(File.join(APP_ROOT, 'config/settings.yml'))

  FileUtils.mkpath(File.join(APP_ROOT, 'building_area/hot_files/'))

  require_relative 'knocker/tools/builder'
  require_relative 'knocker/tools/runner'
  require_relative 'knocker/tools/committer'
end
