# coding: utf-8

require_relative 'knocker/etc/settings'
require 'fileutils'

module Knocker
  APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  Settings.load!(File.join(APP_ROOT, 'config/settings.yml'))

  FileUtils.mkpath(File.join(APP_ROOT, 'building_area/hot_files/'))

  require_relative 'knocker/stand/stand'
  require_relative 'knocker/stand/wizard'
  require_relative 'knocker/stand/docker/image_builder'
  require_relative 'knocker/stand/docker/container_runner'
  require_relative 'knocker/clis/informer'
end
