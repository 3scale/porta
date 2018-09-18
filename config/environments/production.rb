System::Application.configure do

  config.eager_load = true

  config.active_record.dump_schema_after_migration = false
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info').downcase.to_sym

  config.cache_classes = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.active_support.deprecation = :notify

  # ip spoofing checks are pointless and might mess up proxies
  config.action_dispatch.ip_spoofing_check = false

  # we precompile in production
  config.assets.compile = false
  config.assets.compress = true
  config.assets.digest = ENV.fetch('DISABLE_DIGEST', '0') != '1'

  if config.assets.digest
    asset_host = config.three_scale.asset_host.presence

    config.asset_host = ->(source) do
      # does it exist in /public/assets ?
      full_path = File.join(Rails.public_path, source)
      precompiled = File.exist?(full_path)

      break unless precompiled

      asset_host
    end
  end

  # do not change the tags withotu updating logstash rules
  # https://github.com/3scale/puppet/blob/ac161671aee2019eefa87b51b150cb78fcb417e9/modules/logstash/templates/config/system-mt/filter.erb
  config.log_tags = [ :uuid, :host, :remote_ip ]

  config.static_cache_control = "public, max-age=#{(config.assets.digest ? 1.year : 1.minute).to_i}"
  config.serve_static_files = true
  config.middleware.insert_before ActionDispatch::Static, Rack::Deflater

  config.liquid.resolver_caching = true

  config.three_scale.payments.enabled = true

  config.three_scale.rolling_updates.raise_error_unknown_features = false
  config.three_scale.rolling_updates.enabled = ENV.fetch('THREESCALE_ROLLING_UPDATES', '0') == '0'
end
