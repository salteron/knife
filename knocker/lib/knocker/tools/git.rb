# -*- encoding : utf-8 -*-

module Knocker
  module Git
    module_function

    def branch_exists?(project, branch)
      # TODO: смотреть откуда приходит project, вдруг его нет (bz)
      cmd = 'git ls-remote --heads --exit-code' \
            " git@github.com:#{repo}/#{project}.git #{branch}"

      `#{cmd}`

      $?.success?
    end

    # list all remote branches of specified project in repository
    def branches(project)
      cmd = "git ls-remote --heads git@github.com:#{repo}/#{project}.git |" \
            " cut -f2 | sed 's/refs\\/heads\\///g'"

      `#{cmd}`.strip.split
    end

    def last_commit_hash(project, branch)
      cmd = "git ls-remote --heads git@github.com:#{repo}/#{project}.git" \
            " #{branch} | cut -f1"

      `#{cmd}`.strip
    end

    def repo
      Settings.application[:repository]
    end
  end
end
