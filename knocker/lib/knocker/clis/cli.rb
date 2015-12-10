# coding: utf-8

require 'slop'
require_relative '../../knocker.rb'

module Knocker
  class CLI
    def start
      Slop.parse(help: true) do
        on '-v', 'Print the version' do
          puts 'Version 1.0.1'
          exit
        end

        command 'run' do
          on :l, :list, 'List available environments and branches' do
            Knocker::Informer.list_environments
            Knocker::Informer.list_branches
            exit
          end

          on :e=, :environment=, 'Environment to run (default: base)'
          on :b=, :branch=, 'Branch to run'
          on :a=, :alias=, 'Container alias', argument: :optional

          run do |opts|
            unless opts[:branch]
              puts(opts)
              exit 1
            end

            Knocker::Wizard.create(opts[:environment] || Image::BASE_ENV,
                                        opts[:branch],
                                        opts[:alias])
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

            Knocker::Wizard.open(opts[:container]).save(opts[:environment])
          end
        end

        command 'clean' do
          on :l, :list, 'List running containers' do
            Knocker::Informer.list_containers
            exit
          end

          on :a, :all, 'Clean up all containers (even running)' do
            Knocker::Cleaner.clean_all
            exit
          end

          on :s, :stale, 'Clean up all stale (stopped and old containers)' do
            Knocker::Cleaner.clean_stale
            exit
          end

          on :c=, :container=, 'Name of a container to be cleaned up'

          run do |opts|
            unless opts[:container]
              puts(opts)
              exit
            end

            Knocker::Wizard.open(opts[:container]).delete
          end
        end

        command 'knife_prepare' do
          run do |opts|

          end
        end

        command 'admin' do
          command 'build' do
            on :l, :list, 'List available images and code branches' do
              Knocker::Informer.list_images
              Knocker::Informer.list_branches
              exit
            end

            on :r, :run, 'Run a container after an image is built'

            on :i=, :image=,  'Image name'
            on :b=, :branch=, 'Code branch'

            run do |opts|
              unless opts[:image] && opts[:branch]
                puts(opts)
                exit 1
              end

              image_name = Knocker::ImageBuilder
                .build_from_image_and_branch(opts[:image], opts[:branch]).name

              puts image_name

              Knocker::ContainerRunner.new.run_from_image(image_name) if opts[:run]
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

              container = Knocker::ContainerRunner.run_from_image(opts[:image], opts[:alias])
              Nginx.add_route Stand.new(container)
            end
          end
        end

        command 'list' do
          run do
            Knocker::Informer.list_environments
            Knocker::Informer.list_containers
            Knocker::Informer.list_images
            Knocker::Informer.list_branches

            exit
          end
        end

        run do |opts|
          puts opts
        end
      end
    end
  end
end
