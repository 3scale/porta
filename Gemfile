# on servers we don't have proper LANG
Encoding.default_external = Encoding::UTF_8

source 'https://rubygems.org'

# to not use insecure git protocol
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rack', '~> 2.2.6'

gem 'aws-sdk-rails', '~> 3'
gem 'aws-sdk-s3', '~> 1'

gem 'dotenv-rails', '~> 2.7'
gem 'rails', '~> 6.0'

# Locking mail to 2.7.x, as 2.8 has a regression related to `enable_starttls_auto` setting:
# https://github.com/mikel/mail/blob/2-8-stable/CHANGELOG.rdoc#version-281-unreleased-
# Also, upgrading makes this test fail: SendUserInvitationWorkerTest#test_handles_errors
gem 'mail', '~> 2.7.1'

# Needed for XML serialization of ActiveRecord::Base
gem "activejob-uniqueness", github: "3scale/activejob-uniqueness", branch: "main"
gem 'activemodel-serializers-xml'

gem 'protected_attributes_continued', '~> 1.8.2'

gem 'rails-observers'

gem 'strong_migrations', '~> 0.6.8'

group :assets do
  gem 'coffee-rails', '~> 5.0'
  gem 'non-stupid-digest-assets', '~> 1.0'
  gem 'sprockets-rails'
end

gem 'sass-rails', '~> 5.0.8'

gem 'bcrypt', '~> 3.1.7'
gem 'oauth2', '~> 1.4'
gem 'open_id_authentication'

gem 'i18n'

# Apisonator client
gem 'pisoni', '~> 1.29'

gem '3scale_time_range', '0.0.6'

gem 'statsd-ruby', require: false

# Sidekiq
gem 'sidekiq', '< 6', require: %w[sidekiq sidekiq/web]
gem 'sidekiq-batch', '~> 0.1.6'
gem 'sidekiq-cron', require: %w[sidekiq/cron sidekiq/cron/web]
gem 'sidekiq-lock'
gem 'sidekiq-throttled'

gem 'sidekiq-prometheus-exporter'

# Yabeda metrics
gem 'yabeda-prometheus-mmap'
gem 'yabeda-rails'
gem 'yabeda-sidekiq'

gem 'activemerchant', '~> 1.107.4'
gem 'audited', '~> 5.0.2'
gem 'stripe', '~> 5.28.0' # we need the stripe gem because activemerchant can not generate Stripe's "customers"

gem 'acts_as_list', '~> 0.9.17'
gem 'braintree', '~> 2.93'
gem 'bugsnag', '~> 6.11'
gem 'cancancan', '~> 3.0.0'
gem 'formtastic', '~> 4.0'
gem 'htmlentities', '~>4.3', '>= 4.3.4'
# TODO: Not actively maintained https://github.com/activeadmin/inherited_resources#notice replace with respond_with and fix things the rails way
gem 'inherited_resources', '~> 1.12.0'
gem 'json', '~> 2.3.0'

gem 'mysql2', '~> 0.5.3'

gem '3scale_client', '~> 2.11', require: false
gem 'analytics-ruby', require: false

gem 'dalli'
gem 'faraday', '~> 0.15.3'
gem 'faraday_middleware', '~> 0.13.1'
gem 'mimemagic', '~> 0.3.10'
gem 'nokogiri', '~> 1.13.10'
gem 'secure_headers', '~> 6.3.0'
gem 'redlock'

gem 'acts-as-taggable-on', '~> 8.0'
gem 'baby_squeel', '~> 1.4.3'
gem 'browser'
gem 'diff-lcs', '~> 1.2'
gem 'hiredis', '~> 0.6.3'
gem 'httpclient', github: '3scale/httpclient', branch: 'ssl-env-cert'
gem 'json-schema', git: 'https://github.com/3scale/json-schema.git'
gem 'local-fastimage_resize', '~> 3.4.0', require: 'fastimage/resize'
gem 'paperclip', '~> 6.0'
gem 'prawn'
gem 'prawn-table', git: "https://github.com/prawnpdf/prawn-table.git", branch: "38b5bdb5dd95237646675c968091706f57a7a641"
gem 'prawn-svg'
gem 'rails_event_store', '~> 0.9.0', require: false
gem 'ratelimit'
gem 'recaptcha', '4.13.1', require: 'recaptcha/rails'
gem 'redcarpet', '~>3.5.1', require: false
gem 'RedCloth', '~>4.3', require: false
gem 'redis', '~> 4.1.3', require: ['redis', 'redis/connection/hiredis']
gem 'redis-namespace', '~> 1.7.0'
gem 'rest-client', '~> 2.0.2'
gem 'rubyzip', '~>1.3.0', require: false
gem 'svg-graph', require: false
gem 'swagger-ui_rails', git: 'https://github.com/3scale/swagger-ui_rails.git', branch: 'dev'
gem 'swagger-ui_rails2', git: 'https://github.com/3scale/swagger-ui_rails.git', branch: 'dev-2.1.3'
gem 'thinking-sphinx', '~> 5.5.0'
gem 'ts-datetime-delta', require: 'thinking_sphinx/deltas/datetime_delta'
gem 'will_paginate', '~> 3.3'
gem 'zip-zip', require: false

gem 'acts_as_tree'
gem 'addressable', require: false
gem 'hashie', require: false
gem 'rack-x_served_by', '~> 0.1.1'
gem 'rack-cors'
gem 'roar-rails'

gem 'reform', '~> 2.0.3', require: false

# sanitize params passed to rack
gem 'rack-utf8_sanitizer'

gem 'jwt', '~> 1.5.2', require: false

group :assets do
  gem 'font-awesome-rails', '~> 4.7.0.5'
  gem 'jquery-rails', '~> 4.4'
  gem 'uglifier'

  gem 'active-docs', path: 'vendor/active-docs'
end

gem 'compass-rails', '~> 3.0.2'

gem 'after_commit_queue', '~> 1.1.0'
gem 'state_machines', '~> 0.5.0'
gem 'state_machines-activerecord', '~> 0.8'

# for liquid docs on-fly generation
gem 'commonmarker', '~> 0.23.10'
gem 'escape_utils'
gem 'github-markdown'
gem 'html-pipeline'

# templating
gem 'ruby-openid'
gem 'slim-rails', '~> 3.2'

gem 'draper', '~> 3.1'

group :development do
  gem 'listen'

  gem 'letter_opener', require: ENV.fetch('LETTER_OPENER', '0') == '1'

  gem 'yard', require: false

  gem 'rubocop', '1.39', require: false # Should match codeclimate's rubocop channel defined in .codeclimate.yml
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false

  gem 'reek', '6.01', require: false # Should match codeclimate's stable version of Reek. See https://docs.codeclimate.com/docs/reek
end


gem 'mail_view', '~> 2.0.4'

# legacy from rails 2.3 -
gem 'dynamic_form'
gem 'record_tag_helper', '~> 1.0'

group :test do
  # To remove once migrated all functional tests
  gem 'codecov', :require => false
  gem 'rack-no_animations', '~> 1.0.3'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'simplecov', '~> 0.21.2', require: false

  gem 'capybara', '~>3.35.3', source: 'https://rubygems.org'
  gem 'xpath', '~>3.2.0'

  gem 'chronic'
  gem 'cucumber', '~> 7.0'
  gem 'cucumber-rails', '~> 2.4.0', require: false
  gem 'email_spec', require: false
  gem 'fakefs', require: 'fakefs/safe'
  gem 'launchy'
  gem 'mechanize'
  gem 'selenium-webdriver', '~> 3.142', require: false
  gem 'webmock', '~> 3.8.0'

  gem 'childprocess'

  gem 'equivalent-xml', require: false

  gem 'rspec-rails', '~> 4.1', require: false # version 5.x is needed for Rails 6

  # Reason to use the fork: https://github.com/kucaahbe/rspec-html-matchers/pull/21
  gem 'rspec_api_documentation'
  gem 'rspec-html-matchers', github: '3scale/rspec-html-matchers', branch: 'fix/rspec-3-with-xml-document', require: false

  gem 'shoulda', '~> 4.0'

  gem 'ci_reporter_shell', github: '3scale/ci_reporter_shell', require: false
  gem 'minitest', '5.10.3'
  gem 'minitest-ci', require: false
  gem 'minitest-reporters', require: false
  gem 'minitest-stub-const'
  gem 'rspec_junit_formatter'

  # IMPORTANT: Load 'mocha' after 'shoulda'.
  gem 'mocha', '~> 1.1.0', require: 'mocha/setup'

  # proxy tests
  gem 'database_cleaner', require: false
  gem 'thin', require: false

  # performance tests
  gem "n_plus_one_control"
  gem 'ruby-prof'
  gem 'with_env'

  gem 'pdf-inspector', require: 'pdf/inspector'
end

group :development, :test do
  gem 'bootsnap', '~> 1.16'
  gem 'bullet', '~> 6.1.5'
  gem 'colorize'
  gem 'factory_bot_rails', '~> 6.2'

  gem 'pry-byebug', '>= 3.7.0'
  gem 'pry-doc', '>= 0.8', require: false
  gem 'pry-rails'
  gem 'pry-shell'
  gem 'pry-stack_explorer'

  gem 'unicorn-rails'
end

group :licenses do
  gem 'license_finder', '~> 7.1.0'
end

gem 'webpacker', '5.4.4'

gem 'developer_portal', path: 'lib/developer_portal'
gem 'unicorn', require: false, group: %i[production]

# NOTE: Use ENV['DB'] only to install oracle dependencies
group :oracle do
  oracle = -> { (ENV['ORACLE'] == '1') || ENV.fetch('DATABASE_URL', ENV['DB'])&.start_with?('oracle') }
  gem 'activerecord-oracle_enhanced-adapter', '~> 6.0', install_if: oracle
  gem 'ruby-oci8', require: false, install_if: oracle
end

gem 'kubeclient'

gem 'pg', '~> 0.21.0'
