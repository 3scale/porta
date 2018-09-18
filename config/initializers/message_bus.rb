# frozen_string_literal: true

if Rails.env.test?
  MessageBus.configure(backend: :memory)
  MessageBus.keepalive_interval = 0
  MessageBus.off
else
  MessageBus.redis_config = System::Application.config.redis.merge(db: 8)
  MessageBus.timer.on_error do |error|
    System::ErrorReporting.report_error(error)
  end
  MessageBus.on_middleware_error do |env, error|
    System::ErrorReporting.report_error(error, rack_env: env)
  end
end

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
