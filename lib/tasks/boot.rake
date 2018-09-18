# frozen_string_literal: true

namespace :boot do
  desc 'Tries to connect to Backend'
  task backend: :environment do
    status = ThreeScale::Core::APIClient::Resource.api(:get, {}, uri: 'status').fetch(:response_json)
    puts "Backend Internal API version #{status.fetch(:version).fetch(:backend)} status: #{status.fetch(:status)}"
  end

  desc 'Tries to connect to the database'
  task :database do
    begin
      require 'system/database'
      Rake::Task[:environment].invoke

      # Checks general availability of the server, not the database which is done below.
      # Essentially needed for Oracle that needs to connect with SYSTEM user
      # but doing for all databases does not harm.
      System::Database.ready?

      pool = ActiveRecord::Base.establish_connection
      config = pool.spec.config
      pool.with_connection do
        puts "Connected to #{config.fetch(:adapter)}://#{config.fetch(:username)}@#{config.fetch(:host) { 'localhost' }}/#{config.fetch(:database)}"
      end

      pool.disconnect!
    rescue ActiveRecord::NoDatabaseError => error
      warn "Connected, but database does not exist: #{error}"
      exit true
    rescue StandardError => error
      warn "Connection specification: #{System::Database.configuration_specification.config}"
      warn "Failed to connect to database: #{error} (#{error.class})"

      if (cause = error.cause)
        warn "Caused by: #{cause} (#{cause.class})"
      end

      exit false
    end
  end

  desc 'Tries to connect to Redis'
  task redis: :environment do
    redis = System.redis
    redis.ping
    puts "Connected to #{redis.id}"
  end

  task all: %i[backend database redis]
end

desc 'Tries to connect to external services like Backend, DB, Redis or crashes'
task boot: 'boot:all'

Rake::Task['db:seed'].enhance(['boot:database'])
