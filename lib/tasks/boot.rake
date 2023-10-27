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
      exit false unless System::Database.ready?
    end
  end

  desc 'Tries to connect to Redis'
  task :redis do
    require Rails.root.join('app', 'lib', 'three_scale', 'redis_config')

    redis_config = ThreeScale::RedisConfig.new(Rails.application.config_for(:redis)).config
    pool_config = redis_config.extract!(:size, :pool_timeout)
    pool = ConnectionPool.new(size: pool_config[:size] || 5, timeout: pool_config[:pool_timeout] || 5 ) do
      Redis.new(redis_config)
    end
    pool.with do |redis|
      redis.ping
      puts "Connected to #{redis.id}"
    end
  end

  task all: %i[backend database redis]
end

desc 'Tries to connect to external services like Backend, DB, Redis or crashes'
task boot: 'boot:all'

# Rake::Task['db:seed'].enhance(['boot:database'])
