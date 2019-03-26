# frozen_string_literal: true

namespace :sidekiq do
  desc 'start sidekiq web interface'
  task monitor: :environment do
    require 'sidekiq/web'
    app = Sidekiq::Web
    app.set :environment, Rails.env
    app.set :bind, '0.0.0.0'
    app.set :port, ENV.fetch('PORT', 9494)
    app.run!
  end

  desc 'start sidekiq worker'
  task :worker do
    envs = {}
    envs['RAILS_MAX_THREADS'] = ENV.fetch('RAILS_MAX_THREADS', '1')

    args = []
    args.push(['--index', ENV.fetch('INDEX', '0')])
    args.push(%w[backend_sync billing critical default events low priority web_hooks].flat_map { |queue| ['--queue', queue] })

    exec(envs, 'sidekiq', *args.flatten)
  end

  desc 'Delete all jobs belonging to DeleteObjectHierarchyWorker, DeleteAccountHierarchyWorker and those of DeletePlainObjectWorker that are deleted by association'
  task :clear_delete_hierarchy_queue do
    queue = Sidekiq::Queue.new('low')
    queue.each do |job|
      job_klass = job.klass
      job.delete if %w[DeleteObjectHierarchyWorker DeleteAccountHierarchyWorker].include?(job_klass)
    end

    queue = Sidekiq::Queue.new('default')
    queue.each do |job|
      job.delete if job.klass == 'DeletePlainObjectWorker' && job.args[1].length > 2
    end
  end
end

task sidekiq: %w[sidekiq:worker]
