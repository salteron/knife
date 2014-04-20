# -*- encoding : utf-8 -*-

require 'colorize'
module Knocker
  module Logger
    extend self

    def log(message)
      puts form_log_line(message).green
    end

    def log_error(message)
      puts form_log_line(message).red
      exit 1
    end

    def form_log_line(message)
      "#{Time.now.strftime('%F %T')} : #{message}"
    end
  end
end
