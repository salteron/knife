# -*- encoding : utf-8 -*-

module Knocker
  module Nginx
    extend self

    def reload
      `#{Settings.nginx[:reload_cmd]}`
    end
  end
end
