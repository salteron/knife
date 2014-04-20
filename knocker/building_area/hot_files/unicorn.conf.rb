# -*- encoding : utf-8 -*-

# Sample verbose configuration file for Unicorn (not Rack)
#
# This configuration file documents many features of Unicorn
# that may not be needed for some applications. See
# http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# for a much simpler configuration file.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 6

# Since Unicorn is never exposed to outside clients, it does not need to
# run on the standard HTTP port (80), there is no reason to start Unicorn
# as root unless it's from system init scripts.
# If running the master process as root and the workers as an unprivileged
# user, do this to switch euid/egid in the workers (also chowns logs):
# user "unprivileged_user", "unprivileged_group"

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory "/sites/application/blizko" # available in 0.94.0+

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen 8887, :tcp_nopush => true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 300

# feel free to point this anywhere accessible on the filesystem
pid "/var/run/unicorn/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "/sites/application/blizko/log/unicorn.stderr.log"
stdout_path "/sites/application/blizko/log/unicorn.stdout.log"

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
    GC.copy_on_write_friendly = true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  ActiveRecord::Base.connection_handler.clear_all_connections!

  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # # This allows a new master process to incrementally
  # # phase out the old master process with SIGTTOU to avoid a
  # # thundering herd (especially in the "preload_app false" case)
  # # when doing a transparent upgrade.  The last worker spawned
  # # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  # sleep 1
  if File.exists?(old_pid)
    sleep 5
  end
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # the following is *required* for Rails + "preload_app true",
  ActiveRecord::Base.connection_handler.verify_active_connections!

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)

  # Rails cache_store
  #Rails.cache.instance_variable_get(:@data).reset if Rails.cache.class == ActiveSupport::Cache::MemCacheStore

  # Only works with DalliStore
  Rails.cache.reset

  # CacheMoney cache_store
  $memcache.reset if $memcache.present?

  # ActsAsCached
  ActsAsCached.config[:store].reset if defined?(ActsAsCached)

  $redis.client.reconnect if defined?($redis) && $redis.present?
end

before_exec do |server|
  ENV["RUBYOPT"] = "-rauto_gem -rbundler/setup"
  ENV["TNS_ADMIN"] = "/etc/oracle/"
  ENV["RUBY_HEAP_MIN_SLOTS"] = "2500000"
  ENV["RUBY_HEAP_SLOTS_INCREMENT"] = "1000000"
  ENV["RUBY_HEAP_SLOTS_GROWTH_FACTOR"] = "1"
  ENV["RUBY_GC_MALLOC_LIMIT"] = "50000000"
  ENV["GEM_HOME"] = "/usr/local/rvm/gems/ruby-1.9.3-p374"
  ENV["GEM_PATH"] = "/usr/local/rvm/gems/ruby-1.9.3-p374:/usr/local/rvm/gems/ruby-1.9.3-p374@global"
  ENV["BUNDLE_GEMFILE"] = "/sites/application/blizko/Gemfile"
  Dir.chdir("/sites/application/blizko")
  working_directory "/sites/application/blizko"
  stderr_path "/sites/application/blizko/log/unicorn.stderr.log"
  stdout_path "/sites/application/blizko/log/unicorn.stdout.log"
end
