# coding: utf-8

Core::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  Paperclip.options[:command_path] = "/usr/bin/identify"
  config.cache_classes = true

  config.log_level = :debug
  config.active_support.deprecation = :notify

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching             = true
  config.action_controller.page_cache_directory        = Rails.root.to_s + '/public/cache'
  config.action_controller.asset_host                  = "http://#{ASSETS_HOST}#{":#{ASSETS_PORT}" if defined?(ASSETS_PORT)}"

  # Custom configuration
  # выполнять кеширование запросов для моделей ACtiveRecord, в которые подмешан модуль Core::Extensions::ActiveRecord::CachedQueries
  config.perform_caching_queries = true

  # Compress JavaScripts and CSS
  config.assets.compress = false

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  #config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql


  # Disable delivery errors, bad email addresses will be ignored

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :test
  config.action_mailer.asset_host = "http://#{ASSETS_HOST}#{":#{ASSETS_PORT}" if defined?(ASSETS_PORT)}"

  config.action_mailer.smtp_settings = {
      :address  => 'localhost',
      :port => 25,
      :domain => 'localhost'#,
      #  :authentication  => :login,
      #  :user_name  => 'login',
      #  :password  => 'password'
  }

  # memory log
  config.middleware.use Oink::Middleware

  # Enable threaded mode
  # config.threadsafe!
end
