# frozen_string_literal: true

# config/unicorn.rb
require 'pathname'
require 'etc'

app_path = Pathname.pwd
require app_path.join('lib/prometheus_exporter_port').to_s
require app_path.join('lib/cgroups/tools').to_s

Unicorn::HttpServer::START_CTX[0] = '/usr/local/bin/unicorn'

working_directory app_path.to_s

detect_unicorn_workers = -> do
  workers = ENV['UNICORN_WORKERS']
  return Integer(workers) if workers.to_i.positive?

  worker_multiplier = Integer(ENV['UNICORN_WORKER_MULTIPLIER'] || 2)
  cpus = Cgroups::Tools.available_cpus || Etc.nprocessors

  return cpus * worker_multiplier
end

unicorn_workers_num = detect_unicorn_workers.call
warn "Starting #{unicorn_workers_num} unicorn workers"
worker_processes unicorn_workers_num

# listen to the default port
listen Integer(ENV['PORT'] || 3000)
listen PrometheusExporterPort.call

stderr_path '/dev/stderr'
stdout_path '/dev/stdout'

pids_path = app_path.join('tmp', 'pids')
pid pids_path.join('unicorn.pid').to_s

timeout Integer(ENV['UNICORN_TIMEOUT'] || 40)

preload_app true

before_exec do |_server|
  Dotenv.overload if defined?(Dotenv)
  ENV['BUNDLE_GEMFILE'] = app_path.join('Gemfile').to_s
end

before_fork do |server, _worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)

  if defined?(Rails) && (unicorn_config = Rails.application.config.unicorn)
    unicorn_config.after_fork.map(&:call)
  end
end
