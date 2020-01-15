source 'https://rubygems.org'

# to not use insecure git protocol
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# on servers we don't have proper LANG
Encoding.default_external = Encoding::UTF_8

gem 'aws-sdk', '~> 2'
gem 'aws-sdk-rails', '~> 1.0'

gem 'dotenv-rails', '~> 2.7'
gem 'rails', '4.2.11.1'
#gem 'rails', '5.0.6'
#gem 'activesupport', '4.2.9' # somehow paperclip needs to explicitly lock the version to not use 5.0

gem 'protected_attributes', '~> 1.1.4'
#gem 'protected_attributes_continued', '~> 1.3.0'
gem 'rails-observers'

gem 'strong_migrations'

group :assets do
  gem 'coffee-rails', '~> 4.2'
  gem 'sprockets-rails'
  gem 'non-stupid-digest-assets', '~> 1.0'
end

gem 'sass-rails', '~> 5.0'

gem 'open_id_authentication'
gem 'oauth2', '~> 1.4'
gem 'bcrypt', '~> 3.1.7'

gem 'i18n'

# This is in Rails 5:
# http://blog.bigbinary.com/2016/03/09/rails-5-makes-partial-redering-from-cache-substantially-faster.html
gem 'multi_fetch_fragments', github: 'mikz/multi_fetch_fragments'

# Apisonator client
gem 'pisoni', '~> 1.26'

# 3scale fork that allows OPTIONS passthrough
gem 'font_assets', git: 'https://github.com/3scale/font_assets.git', ref: 'da97b8601528ee189795cc94b953ec9a30f47e83', groups: [:production, :preview]
gem '3scale_time_range', '0.0.6'

gem 'statsd-ruby', require: false

gem 'sinatra', require: false # for sidekiq web

# Sidekiq
gem 'sidekiq', '< 6', require: %w(sidekiq sidekiq/web)
gem 'sidekiq-batch', '~> 0.1.1'
gem 'sidekiq-cron', require: %w(sidekiq/cron sidekiq/cron/web)
gem 'sidekiq-lock'
gem 'sidekiq-throttled'

gem 'sidekiq-prometheus-exporter'

# Yabeda metrics
gem 'yabeda-sidekiq'
gem 'prometheus-client-mmap'
gem 'yabeda-prometheus'

gem 'activemerchant', '~> 1.77.0'
gem 'active_merchant-adyen12', github: '3scale/active_merchant-adyen12'
gem 'money', '6.7.1' # Lock to this version we use in production
gem 'stripe', '~> 1.58.0' # we need the stripe gem because activemerchant can not generate Stripe's "customers"
gem 'audited'

# Rails 4.1: this should not be needed, maybe replace it with enum -- http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html
# TODO: replace with enum because it is not compatible with rails 5.x and not maintained
gem 'symbolize', '~> 4.5'
gem 'acts_as_list', '~> 0.9.17'
gem 'braintree', '~> 2.89'
gem 'cancancan', '~> 1.7.1'
gem 'formtastic', '~> 1.2.4'
gem 'rmagick', '~> 2.15.3', require: false
gem 'gruff', '~>0.3', require: false
gem 'bugsnag', '~> 6.11'
gem 'htmlentities', '~>4.3', '>= 4.3.4'
# TODO: Not actively maintained https://github.com/activeadmin/inherited_resources#notice replace with respond_with and fix things the rails way
gem 'inherited_resources', '~> 1.7.2'
gem 'json', '~> 1.8.1'

gem 'mysql2', '~>0.3.11'
gem 'pg', '~> 0.21.0'

gem '3scale_client', '~> 2.6.1', require: false
gem 'analytics-ruby', require: false

group :development, :test do
  gem 'bootsnap', '~> 1.3'

  platform :mri_23, :mri_24, :mri_25 do
    gem 'pry-byebug', '>= 3.7.0', require: false
    gem 'pry-stack_explorer', require: false
  end
end

gem 'nokogiri', '>= 1.6.8'
gem 'dalli', '~> 2.7'
gem 'secure_headers', '~> 2.2'
gem 'faraday', '~> 0.12.0'
gem 'faraday_middleware', '~> 0.13.1'

gem 'rails_event_store', '~> 0.9.0'
gem 'paperclip', '~> 5.3.0'
gem 'zip-zip', require: false
gem 'rubyzip', '~>1.3.0', require: false
gem 'prawn-core', git: 'https://github.com/3scale/prawn.git', branch: '0.5.1-3scale'
gem 'prawn-format', '0.2.1'
gem 'prawn-layout', '0.2.1'
gem 'swagger-ui_rails2', git: 'https://github.com/3scale/swagger-ui_rails.git', branch: 'dev-2.1.3'
gem 'swagger-ui_rails', git: 'https://github.com/3scale/swagger-ui_rails.git', branch: 'dev'
gem 'json-schema', git: 'https://github.com/3scale/json-schema.git'
gem 'RedCloth', '~>4.3', require: false
gem 'redcarpet', '~>3.4.0', require: false
gem 'baby_squeel', '~> 1.3.1'
gem 'recaptcha', '4.13.1', require: 'recaptcha/rails'
gem 'hiredis', '~>0.6.0'
gem 'redis', '~> 3.3.5', require: ['redis', 'redis/connection/hiredis']
gem 'ratelimit'
gem 'redis-namespace', '~> 1.5.2'
gem 'rest-client', '~> 2.0.2'
gem 'httpclient', github: 'mikz/httpclient', branch: 'ssl-env-cert'
gem 'thinking-sphinx', '~> 3.0'
gem 'ts-datetime-delta', require: 'thinking_sphinx/deltas/datetime_delta'
gem 'diff-lcs', '~> 1.2'
gem 'acts-as-taggable-on', '~> 4.0'
gem 'whenever', '~> 0.9.7', require: false
gem 'will_paginate', '~> 3.1.0'
gem 'browser'

gem 'rack-x_served_by', '~> 0.1.1'
gem 'deadlock_retry'
gem 'addressable', require: false
gem 'roar-rails'
gem 'acts_as_tree'
gem 'hashie', require: false

gem 'reform', '~> 2.0.3', require: false

# sanitize params passed to rack
gem 'rack-utf8_sanitizer'

gem 'jwt', '~> 1.5.2', require: false

group :assets do
  gem 'uglifier'
  gem 'font-awesome-rails', '~> 4.7.0.5'
  gem 'codemirror-rails', '~> 5.6'
  gem 'jquery-rails', '~> 4.3'

  gem 'active-docs', path: 'vendor/active-docs'
end

gem 'compass-rails', '~> 3.0.2'

gem 'state_machines', '~> 0.5.0'
gem 'state_machines-activerecord', '~> 0.5.0'
gem 'after_commit_queue', '~> 1.1.0'

# for liquid docs on-fly generation
gem 'html-pipeline', github: 'ceritium/html-pipeline', branch: 'master'
gem 'github-markdown'

# templating
gem 'slim-rails', '~> 3.2'
gem 'ruby-openid'

gem 'draper', '~> 2.0'
# TODO: gem 'draper', '~> 3.0'

group :development do
  gem 'bullet', '~> 4.2'

  gem 'letter_opener', require: false if ENV.fetch('LETTER_OPENER', '1') == '0'

  gem 'yard', require: false

  # Install rubocop only when using RubyMine (for the rubocop plugin)
  gem 'rubocop', '0.52.1', install_if: ENV['TEAMCITY_RAKE_RUNNER_MODE'], require: false
end

gem 'message_bus', '~> 2.0.2'
gem 'message_bus_client', github: '3scale/message_bus_client'

gem 'mail_view', '~> 2.0.4'

# legacy from rails 2.3 -
gem 'dynamic_form'

group :test do
  gem 'codecov', '~> 0.1.10', :require => false
  gem 'rack-no_animations', '~> 1.0.3'
  gem 'simplecov', '~> 0.10.0'

  gem 'capybara', '~> 2.18', source: 'https://rubygems.org'
  gem 'xpath', '~>2.1'

  gem 'selenium-webdriver', '~> 3.4', require: false
  gem 'chronic'
  gem 'cucumber', '~>2.0'
  gem 'cucumber-rails', require: false
  gem 'email_spec', require: false
  gem 'fakefs', '~>0.18.0', require: 'fakefs/safe'
  gem 'webmock', '~> 2.3.2'
  gem 'launchy'
  gem 'mechanize'

  gem 'childprocess'

  gem 'equivalent-xml', require: false

  gem 'rspec-rails', '~> 3.8', require: false # version 3 and up require capybara >= 2.2

  # Reason to use the fork: https://github.com/kucaahbe/rspec-html-matchers/pull/21
  gem 'rspec-html-matchers', github: '3scale/rspec-html-matchers', branch: 'fix/rspec-3-with-xml-document', require: false
  gem 'rspec_api_documentation'

  gem 'shoulda', '~> 3.5.0', require: false
  gem 'shoulda-matchers', '~> 2.8.0'
  gem 'shoulda-context', '~> 1.2.2'
  gem 'timecop', '~> 0.9'

  gem 'minitest'
  gem 'minitest-reporters', require: false
  gem 'minitest-stub-const'
  gem 'ci_reporter_shell', github: '3scale/ci_reporter_shell', require: false
  gem 'rspec_junit_formatter'

  # IMPORTANT: Load 'mocha' after 'shoulda'.
  gem 'mocha', '~> 1.1.0', require: 'mocha/setup'

  # proxy tests
  gem 'thin', require: false
  gem 'database_cleaner', '~> 1.7', require: false

  # performance tests
  gem 'ruby-prof'

  gem 'percy-capybara', '~> 2.5.1', require: false
  gem 'm', '~> 1.5.1' # To be removed in rails 5.0
end

group :development, :test do
  gem 'colorize'
  gem 'factory_bot_rails', '~> 4.11.1'
  gem 'unicorn-rails'

  gem 'pry-rails'
  gem 'pry-doc', '>= 0.8', require: false

  gem 'license_finder', '~> 5.5.2'

  # to generate the swagger JSONs
  gem 'sour', github: 'HakubJozak/sour', require: false

  # for `rake doc:liquid:generate` and similar
  gem 'source2swagger', git: 'https://github.com/3scale/source2swagger'
end

gem 'webpacker', '~> 4.x'

gem 'unicorn', require: false, group: [:production, :preview]
gem 'developer_portal', path: 'lib/developer_portal'

# NOTE: Use ENV['DB'] only to install oracle dependencies
oracle = lambda { (ENV['ORACLE'] == '1') || ENV.fetch('DATABASE_URL', ENV['DB'])&.start_with?('oracle') }
gem 'activerecord-oracle_enhanced-adapter', '~> 1.6.0', install_if: oracle
gem 'ruby-oci8', require: false, install_if: oracle

gem 'kubeclient'
