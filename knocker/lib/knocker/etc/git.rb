# coding: utf-8

module Knocker
  module Git
    extend self

    def validate!(code_branch)
      unless branch_exists?(code_branch)
        fail "branch '#{code_branch}' doesn't exist"
      end
    end

    def branch_exists?(branch)
      repo = Settings.application[:repository]
      project = Settings.application[:default_project]

      cmd = 'git ls-remote --heads --exit-code' \
            " git@github.com:#{repo}/#{project}.git #{branch}"

      `#{cmd}`

      $?.success?
    end

    # list all remote branches of specified project in repository
    def branches(project)
      repo = Settings.application[:repository]
      project = Settings.application[:default_project]

      cmd = "git ls-remote --heads git@github.com:#{repo}/#{project}.git |" \
            " cut -f2 | sed 's/refs\\/heads\\///g'"

      `#{cmd}`.strip.split
    end

    def last_commit_hash(branch)
      repo = Settings.application[:repository]
      project = Settings.application[:default_project]

      cmd = "git ls-remote --heads git@github.com:#{repo}/#{project}.git" \
            " #{branch} | cut -f1"

      `#{cmd}`.strip
    end
  end
end
