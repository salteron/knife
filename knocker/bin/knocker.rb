#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

require 'slop'
require_relative '../lib/knocker.rb'

Slop.parse(strict: true, help: true) do
  on '-v', 'Print the version' do
    puts 'Version 1.0'
    exit
  end

  command 'build' do
    on :l, :list, 'List available images and code branches' do
      Knocker::Informer.list_images
      Knocker::Informer.list_branches
      exit
    end

    # TODO: для каналов (knocker build ... | xargs knocker run)
    on :q, :quite, 'Quite mode'

    on :i=, :image=,  'Image name'
    on :b=, :branch=, 'Code branch'

    run do |opts|
      unless opts[:image] && opts[:branch]
        puts(opts)
        exit 1
      end

      puts Knocker::Builder.new.build_from_image_and_branch(opts[:image],
                                                            opts[:branch])
    end
  end

  command 'run' do
    on :l, :list, 'List available images' do
      Knocker::Informer.list_images
      exit
    end

    on :i=, :image=, 'Image name to run'
    on :a=, :alias=, 'Container alias', argument: :optional

    run do |opts|
      unless opts[:image]
        puts(opts)
        exit 1
      end

      if opts[:alias]
        Knocker::Runner.new.run_from_image(opts[:image], opts[:alias])
      else
        Knocker::Runner.new.run_from_image(opts[:image])
      end
    end
  end

  command 'commit' do
    on :l, :list, 'List running containers' do
      Knocker::Informer.list_containers
      exit
    end

    on :c=, :container=,   'Name of a container to be committed'
    on :e=, :environment=, 'Environment name for a new image'

    run do |opts|
      unless opts[:container] && opts[:environment]
        puts(opts)
        exit 1
      end

      Knocker::Committer.new.commit_container_to_image(opts[:container],
                                                       opts[:environment])
    end
  end

  run do |opts|
    puts opts
  end
end
