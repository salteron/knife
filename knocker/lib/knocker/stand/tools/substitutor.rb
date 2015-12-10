# coding: utf-8

module Knocker
  module Substitutor
    extend self

    def sub(template, target, substitution)
      content = File.read(template)

      substitution.keys.each do |key|
        content.gsub!("%#{key}%", substitution[key])
      end

      File.write(target, content)
    end
  end
end
