# on servers we don't have proper LANG
Encoding.default_external = Encoding::UTF_8

source 'https://rubygems.org'

# to not use insecure git protocol
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rack', '~> 2.1.4'

gem 'aws-sdk', '~> 3'
gem 'aws-sdk-rails', '~> 2'
gem 'aws-sdk-s3', '~> 1'

gem 'dotenv-rails', '~> 2.7'
gem 'rails', '~> 5.1.7'

# Needed for XML serialization of ActiveRecord::Base
gem "activejob-uniqueness", github: "3scale/activejob-uniqueness", branch: "main"
gem 'activemodel-serializers-xml'

gem 'protected_attributes_continued', '~> 1.3.0'

gem 'rails-observers'

gem 'strong_migrations', '~> 0.6.8'

group :assets do
  gem 'coffee-rails', '~> 4.2'
  gem 'non-stupid-digest-assets', '~> 1.0'
  gem 'sprockets-rails'
end

gem 'sass-rails', '~> 5.0'

gem 'bcrypt', '~> 3.1.7'
gem 'oauth2', '~> 1.4'
gem 'open_id_authentication'

gem 'i18n'

# Apisonator client
gem 'pisoni', '~> 1.29'

gem '3scale_time_range', '0.0.6'

gem 'statsd-ruby', require: false

gem 'sinatra', require: false # for sidekiq web

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
gem 'audited'
gem 'stripe', '~> 5.28.0' # we need the stripe gem because activemerchant can not generate Stripe's "customers"

gem 'acts_as_list', '~> 0.9.17'
gem 'braintree', '~> 2.93'
gem 'bugsnag', '~> 6.11'
gem 'cancancan', '~> 2.3.0'
gem 'formtastic', '~> 1.2.4'
gem 'gruff', '~>0.3', require: false
gem 'htmlentities', '~>4.3', '>= 4.3.4'
gem 'rmagick', '~> 2.15.3', require: false
# TODO: Not actively maintained https://github.com/activeadmin/inherited_resources#notice replace with respond_with and fix things the rails way
gem 'inherited_resources', '~> 1.7.2'
gem 'json', '~> 2.3.0'

gem 'mysql2', '~> 0.5.3'

gem '3scale_client', '~> 2.11', require: false
gem 'analytics-ruby', require: false

gem 'dalli', '~> 2.7'
gem 'faraday', '~> 0.15.3'
gem 'faraday_middleware', '~> 0.13.1'
gem 'mimemagic', '~> 0.3.10'
gem 'nokogiri', '~> 1.10.10'
gem 'secure_headers', '~> 6.3.0'

gem 'acts-as-taggable-on', '~> 4.0'
gem 'baby_squeel', '~> 1.3.1'
gem 'browser', '~> 5.0.0' # we can update to lts when we stop using ruby 2.4
gem 'diff-lcs', '~> 1.2'
gem 'hiredis', '~> 0.6.3'
gem 'httpclient', github: 'mikz/httpclient', branch: 'ssl-env-cert'
gem 'json-schema', git: 'https://github.com/3scale/json-schema.git'
gem 'paperclip', '~> 6.0'
gem 'prawn-core', git: 'https://github.com/3scale/prawn.git', branch: '0.5.1-3scale'
gem 'prawn-format', '0.2.1'
gem 'prawn-layout', '0.2.1'
gem 'rails_event_store', '~> 0.9.0', require: false
gem 'ratelimit'
gem 'recaptcha', '4.13.1', require: 'recaptcha/rails'
gem 'redcarpet', '~>3.5.1', require: false
gem 'RedCloth', '~>4.3', require: false
gem 'redis', '~> 4.1.3', require: ['redis', 'redis/connection/hiredis']
gem 'redis-namespace', '~> 1.7.0'
gem 'rest-client', '~> 2.0.2'
gem 'rubyzip', '~>1.3.0', require: false
gem 'swagger-ui_rails', git: 'https://github.com/3scale/swagger-ui_rails.git', branch: 'dev'
gem 'swagger-ui_rails2', git: 'https://github.com/3scale/swagger-ui_rails.git', branch: 'dev-2.1.3'
gem 'thinking-sphinx', '~> 5.3.0'
gem 'ts-datetime-delta', require: 'thinking_sphinx/deltas/datetime_delta'
gem 'will_paginate', '~> 3.1.6'
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
  gem 'codemirror-rails', '~> 5.6'
  gem 'font-awesome-rails', '~> 4.7.0.5'
  gem 'jquery-rails', '~> 4.3'
  gem 'uglifier'

  gem 'active-docs', path: 'vendor/active-docs'
end

gem 'compass-rails', '~> 3.0.2'

gem 'after_commit_queue', '~> 1.1.0'
gem 'state_machines', '~> 0.5.0'
gem 'state_machines-activerecord', '~> 0.5.0'

# for liquid docs on-fly generation
gem 'commonmarker'
gem 'escape_utils'
gem 'github-markdown'
gem 'html-pipeline'

# templating
gem 'ruby-openid'
gem 'slim-rails', '~> 3.2'

gem 'draper', '~> 3.0'

group :development do
  gem 'bullet', '~> 5.6'
  gem 'listen'

  gem 'letter_opener', require: ENV.fetch('LETTER_OPENER', '0') == '1'

  gem 'yard', require: false

  gem 'rubocop', '~> 0.92', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
end


gem 'mail_view', '~> 2.0.4'

# legacy from rails 2.3 -
gem 'dynamic_form'
gem 'record_tag_helper', '~> 1.0'

group :test do
  # To remove once migrated all functional tests
  gem 'codecov', :require => false
  gem 'rack-no_animations', '~> 1.0.3'
  gem 'rails-controller-testing'
  gem 'simplecov', '~> 0.21.2', require: false

  gem 'capybara', '~>3.35.3', source: 'https://rubygems.org'
  gem 'xpath', '~>3.2.0'

  gem 'chronic'
  gem 'cucumber', '~> 7.0'
  gem 'cucumber-rails', '~> 2.4.0', require: false
  gem 'email_spec', require: false
  gem 'fakefs', '~>0.18.0', require: 'fakefs/safe'
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

  gem 'shoulda', '~> 3.5.0', require: false
  gem 'shoulda-context', '~> 1.2.2'
  gem 'shoulda-matchers', '~> 2.8.0'
  gem 'timecop', '~> 0.9'

  gem 'ci_reporter_shell', github: '3scale/ci_reporter_shell', require: false
  gem 'minitest', '5.10.3'
  gem 'minitest-ci', require: false
  gem 'minitest-reporters', require: false
  gem 'minitest-stub-const'
  gem 'rspec_junit_formatter'

  # IMPORTANT: Load 'mocha' after 'shoulda'.
  gem 'mocha', '~> 1.1.0', require: 'mocha/setup'

  # proxy tests
  gem 'database_cleaner', '~> 1.7', require: false
  gem 'thin', require: false

  # performance tests
  gem 'ruby-prof'
  gem 'with_env'
end

group :development, :test do
  gem 'bootsnap', '~> 1.4'
  gem 'colorize'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'license_finder', '~> 6.12.0'

  gem 'pry-byebug', '>= 3.7.0'
  gem 'pry-doc', '>= 0.8', require: false
  gem 'pry-rails'
  gem 'pry-shell'
  gem 'pry-stack_explorer'
  # to generate the swagger JSONs
  gem 'sour', github: 'HakubJozak/sour', require: false

  # for `rake doc:liquid:generate` and similar
  gem 'source2swagger', git: 'https://github.com/3scale/source2swagger'
  gem 'unicorn-rails'
end

gem 'webpacker', '~> 4'

gem 'developer_portal', path: 'lib/developer_portal'
gem 'unicorn', require: false, group: %i[production preview]

# NOTE: Use ENV['DB'] only to install oracle dependencies
oracle = -> { (ENV['ORACLE'] == '1') || ENV.fetch('DATABASE_URL', ENV['DB'])&.start_with?('oracle') }
gem 'activerecord-oracle_enhanced-adapter', '~> 1.8.0', install_if: oracle
gem 'ruby-oci8', require: false, install_if: oracle

gem 'kubeclient'

gem 'pg', '~> 0.21.0'
