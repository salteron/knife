# -*- encoding : utf-8 -*-
require 'fileutils'

module Knocker
  module Nginx
    extend self

    def reload
      `#{Settings.nginx[:reload_cmd]}`
    end

    def rm_vhosts(vhosts_names)
      vhosts_names
        .map { |v_name| File.join(Settings.nginx[:vhosts_dir], v_name) }
        .each { |vhost| FileUtils.rm_f(vhost) }

      reload
    end
  end
end
