# coding: utf-8

module Knocker
  # Validator and converter for user params:
  #   - container alias  (image naming, url)
  #   - environment name (image naming, url)
  #   - branch name      (image naming, url)
  module NameKnockerizer
    extend self

    # one-line string
    # formed by words of downcase-alpha-numeric chars
    # joined by hyphens;
    # meets docker, url and dir name constraints
    VALID_NAME_REGEXP = /
      \A
      (
        [a-z0-9]+
        \-*
      )*
      ([a-z0-9])+
      \z
    /x

    # Validate name with VALID_NAME_REGEXP and
    # fail in case of mismatch
    def validate!(name)
      msg = "Invalid parameter (#{name}), only [a-z0-9-] are allowed"
      fail msg unless valid?(name)
    end

    # Validate name with VALID_NAME_REGEXP
    def valid?(name)
      name.match(VALID_NAME_REGEXP)
    end

    # Replace forbidden by VALID_NAME_REGEXP chars with hyphens and
    # return valid name
    def knockerize(name)
      name
      .downcase
      .gsub(/[^a-z0-9]/, '-')
      .gsub(/(\-)+/, '-') # squash hyphens
    end
  end
end
