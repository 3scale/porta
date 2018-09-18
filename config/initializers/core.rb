fake_server = System::Application.config.three_scale.core.fake_server

if fake_server && ENV.fetch('UNICORN_WORKERS', 1).to_i > 1
  ThreeScale::Core.url = fake_server
else
  ThreeScale::Core.url = System::Application.config.three_scale.core.url or raise 'Missing url configuration'
end

ThreeScale::Core.username = Rails.configuration.three_scale.core.username
ThreeScale::Core.password =  Rails.configuration.three_scale.core.password
faraday = ThreeScale::Core.faraday
faraday.options.timeout = 5
faraday.options.open_timeout = 3

Rails.logger.info "[Core] Using #{ThreeScale::Core.url} as URL"
