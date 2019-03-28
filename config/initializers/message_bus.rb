# frozen_string_literal: true

# Monkey patching message_bus to enforce redis namespace
require 'message_bus/backends/redis'

class MessageBus::Redis::ReliablePubSub
  def new_redis_connection
    ::Redis.new_with_namespace(@redis_config.symbolize_keys)
  end
end

Class.new do
  def initialize(message_bus_config = {})
    @config = message_bus_config.dup

    @enabled = config.delete(:enabled)
    @redis_config = config.delete(:redis)
  end

  attr_reader :config, :enabled, :redis_config

  def configure_message_bus!
    MessageBus.configure(config)
    MessageBus.redis_config = redis_config if redis_config.present?

    return MessageBus.off unless enabled

    MessageBus.timer.on_error do |error|
      System::ErrorReporting.report_error(error)
    end
    MessageBus.on_middleware_error do |env, error|
      System::ErrorReporting.report_error(error, rack_env: env)
    end
  end
end.new(Rails.configuration.three_scale.message_bus).configure_message_bus!

authenticated_request = lambda do |env|
  ActiveRecord::Base.connection_pool.with_connection do
    (env['authenticated_request'] ||= AuthenticatedSystem::Request.new(ActionDispatch::Request.new(env)))
  end
end

MessageBus.user_id_lookup do |env| # user_id
  authenticated_request[env].user_id
end

MessageBus.group_ids_lookup do |env| # account_id
  Array(authenticated_request[env].account_id)
end

MessageBus.extra_response_headers_lookup do
  # to configure nginx proxy_buffering
  { 'X-Accel-Buffering' => 'no' }
end

MessageBus.site_id_lookup do |env = {}| # provider_id
  if env.empty?
    user = User.current

    next unless user # this happens when publishing keepalive

    user.account.to_gid_param
  else
    ActiveRecord::Base.connection_pool.with_connection do
      request = ActionDispatch::Request.new(env)
      provider = SiteAccountSupport::Request.new(request).find_provider
      param = provider.to_gid_param
      Rails.logger.debug { "[MessageBus] site_id_lookup #{param}"}
      param
    end
  end
end
