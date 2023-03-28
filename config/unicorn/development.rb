# frozen_string_literal: true

require 'pathname'

app_dir = Pathname.new(File.dirname(__FILE__) + "/../..").realpath

require app_dir.join('lib/prometheus_exporter_port').to_s

ENV['RAILS_ENV'] ||= 'development'

worker_processes((ENV["UNICORN_WORKERS"] || "1").to_i)

# Do not preload app to save the memory
preload_app false

# Restart any workers that haven't responded in 300 seconds
timeout 300

# Listen on a Unix data socket
listen ENV.fetch('PORT', 3000).to_i

prometheus_port = PrometheusExporterPort.call
$stdout.puts "=> Unicorn Prometheus endpoint http://localhost:#{prometheus_port}/metrics"
$stdout.puts "=> Unicorn Prometheus endpoint http://localhost:#{prometheus_port}/yabeda-metrics"
listen prometheus_port

pid app_dir.join('tmp/pids/unicorn.pid').to_s

if ENV.fetch('RAILS_LOG_TO_STDOUT', '1') != '1'
  stderr_path app_dir.join("log/unicorn.stderr.log").to_s
  stdout_path app_dir .join("log/unicorn.stdout.log").to_s
end

# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

before_fork do |server, worker|
  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # This allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade.  The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
      $stdout.puts "Process already killed..."
    end
  end

  # Allow graceful shutdown when running in a container with SIGTERM.
  # It is mostly safe that we revert SIGQUIT to DEFAULT for short
  # because there are still no workers spawned at this point.
  # If you want quick shutdown, send SIGINT
  quit_handler = trap(:QUIT, "DEFAULT")
  trap(:QUIT, quit_handler)
  trap(:TERM, quit_handler)
end


after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  # ActiveRecord::Base.establish_connection
  # Redis and Memcached would go here but their connections are established
  # on demand, so the master never opens a socket


  ##
  # Unicorn master is started as root, which is fine, but let's
  # drop the workers to git:git

  # begin
  #   uid, gid = Process.euid, Process.egid
  #   user, group = 'www-seslost', 'seslost'
  #   target_uid = Etc.getpwnam(user).uid
  #   target_gid = Etc.getgrnam(group).gid
  #   worker.tmp.chown(target_uid, target_gid)
  #   if uid != target_uid || gid != target_gid
  #     Process.initgroups(user, target_gid)
  #     Process::GID.change_privilege(target_gid)
  #     Process::UID.change_privilege(target_uid)
  #   end
  # rescue => e
  #   if ENV['RAILS_ENV'] == 'development'
  #     STDERR.puts "couldn't change user, oh well"
  #   else
  #     raise e
  #   end
  # end
end
