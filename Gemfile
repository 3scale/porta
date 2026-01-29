# on servers we don't have proper LANG
Encoding.default_external = Encoding::UTF_8

source 'https://rubygems.org'

# to not use insecure git protocol
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rack', '~> 2.2.20'

gem 'aws-sdk-rails', '~> 3'
gem 'aws-sdk-s3', '~> 1'

gem 'dotenv-rails', '~> 2.7'
gem 'rails', '~> 7.1.5'

gem 'mail', '~> 2.8.1'

gem "activejob-uniqueness"
# Needed for XML serialization of ActiveRecord::Base
gem 'activemodel-serializers-xml'

gem 'protected_attributes_continued', '~> 1.9.0'

gem 'rails-observers'

gem 'strong_migrations', '~> 2.1.0'

gem 'sprockets-rails'

group :assets do
  gem 'coffee-rails', '~> 5.0'
  gem 'cssbundling-rails', '~> 1.4.3'
  gem 'non-digest-assets', '~> 2.4.0'
end

gem 'bcrypt', '~> 3.1.7'
gem 'oauth2', '~> 2.0'
gem 'open_id_authentication'

gem 'sorted_set', '~> 1.0'

gem 'i18n'

# Apisonator client
gem 'pisoni', '~> 1.30'

gem '3scale_time_range', '0.0.6'

gem 'statsd-ruby', require: false

# Sidekiq
gem 'sidekiq', '~> 7', require: %w[sidekiq sidekiq/web]
gem 'sidekiq-batch', '~> 0.2.0'
gem 'sidekiq-cron', require: %w[sidekiq/cron sidekiq/cron/web]
gem 'sidekiq-throttled', '~> 1.4.0'

# Yabeda metrics
gem 'webrick', '~> 1.8.2'
gem 'yabeda-prometheus-mmap'
gem 'yabeda-sidekiq'

gem 'activemerchant', '~> 1.137'
gem 'audited', '~> 5.4.2'
gem 'stripe', '~> 5.28.0' # we need the stripe gem because activemerchant can not generate Stripe's "customers"

gem 'acts_as_list', '~> 0.9.17'
gem 'braintree', '~> 4.25.0'
gem 'libxml-ruby', '~> 5.0.5' # Optional, makes braintree faster
gem 'bugsnag', '~> 6.26'
gem 'cancancan', '~> 3.6.0'
gem 'formtastic', '~> 5.0'
gem 'htmlentities', '~>4.3', '>= 4.3.4'
# TODO: Not actively maintained https://github.com/activeadmin/inherited_resources#notice replace with respond_with and fix things the rails way
gem 'inherited_resources', '~> 1.14.0'
gem 'json', '~> 2.7', '>= 2.7.1'

gem 'mysql2', '~> 0.5.3'

gem '3scale_client', '~> 2.11', require: false
gem 'analytics-ruby', require: false

gem 'dalli'
gem 'faraday', '~> 2.0', '<= 2.9'
gem 'mimemagic', '~> 0.3.10'
gem 'nokogiri', '~> 1.18.9', force_ruby_platform: true
gem 'secure_headers', '~> 6.3.0'
gem 'redlock'

gem 'acts-as-taggable-on', '~> 11.0'
gem 'baby_squeel', '~> 3.0', '>= 3.0.0'
gem 'browser'
gem 'diff-lcs', '~> 1.2'
gem 'hiredis-client'
gem 'httpclient', github: '3scale/httpclient', branch: 'ssl-env-cert'
gem 'json_schemer'
gem 'local-fastimage_resize', '~> 3.4.0', require: 'fastimage/resize'
gem 'kt-paperclip', '~> 7.2'
gem 'matrix', '~> 0.4.2' # needed only until we upgrade capybara and prawn that list it as a dependency
gem 'prawn'
gem 'prawn-table', git: "https://github.com/prawnpdf/prawn-table.git", branch: "38b5bdb5dd95237646675c968091706f57a7a641"
gem 'prawn-svg'
gem 'rails_event_store', '~> 0.9.0', require: false
gem 'ratelimit'
gem 'recaptcha', '~> 5.16.0'
gem 'redcarpet', '~>3.5.1', require: false
gem 'RedCloth', '~>4.3', require: false
gem 'redis'
gem 'rest-client', '~> 2.0.2'
gem 'rubyzip', '~>1.3.0', require: false
gem 'svg-graph', require: false
gem 'swagger-ui_rails', git: 'https://github.com/3scale/swagger-ui_rails.git', branch: 'dev'
gem 'swagger-ui_rails2', git: 'https://github.com/3scale/swagger-ui_rails.git', branch: 'dev-2.1.3'
gem 'thinking-sphinx', '~> 5.6.0'
gem 'ts-datetime-delta', require: 'thinking_sphinx/deltas/datetime_delta'
gem 'will_paginate', '~> 3.3'
gem 'zip-zip', require: false

# TODO: this gem seems a bit abandoned, consider getting rid of it
gem 'acts_as_tree', '~> 2.9.1'
gem 'addressable', require: false
gem 'hashie', require: false
gem 'rack-x_served_by', '~> 0.1.1'
gem 'rack-cors'
gem 'roar-rails'

gem 'reform', '~> 2.3.0', require: false
gem 'reform-rails', '~> 0.2.2', require: false

# sanitize params passed to rack
gem 'rack-utf8_sanitizer'

gem 'jwt', '~> 1.5.2', require: false

group :assets do
  gem 'jquery-rails', '4.6'
  gem 'uglifier'

  gem 'active-docs', path: 'vendor/active-docs'
end

gem 'after_commit_queue', '~> 1.1.0'
gem 'state_machines', '~> 0.5.0'
gem 'state_machines-activerecord', '~> 0.8'

# for liquid docs on-fly generation
gem 'commonmarker', '~> 0.23.10'
gem 'escape_utils'
gem 'html-pipeline', '~> 2.14.3'

# templating
gem 'ruby-openid'
gem 'slim-rails', '~> 3.2'

gem 'draper', '~> 4.0.2'

group :development do
  gem 'listen'

  gem 'letter_opener', require: ENV.fetch('LETTER_OPENER', '0') == '1'

  gem 'yard', require: false

  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false

  gem 'reek', require: false
end


gem 'mail_view', '~> 2.0.4'

group :test do
  gem 'rack-no_animations', '~> 1.0.3'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'simplecov', '~> 0.22.0', require: false
  gem 'simplecov-cobertura', '~> 3.1', require: false

  gem 'capybara', '~>3.40.0'
  gem 'xpath', '~>3.2.0'

  gem 'chronic'
  gem 'cucumber', '~> 7.0'
  gem 'cucumber-rails', '~> 3.0.0', require: false
  gem 'email_spec', require: false
  gem 'fakefs', require: 'fakefs/safe'
  gem 'launchy'
  gem 'mechanize'
  gem 'selenium-webdriver', '~> 4.25', require: false
  gem 'webmock', '~> 3.24.0'

  gem 'childprocess'

  gem 'equivalent-xml', require: false

  gem 'rspec-rails', '~> 7.1', require: false

  # Reason to use the fork: https://github.com/kucaahbe/rspec-html-matchers/pull/21
  gem 'rspec_api_documentation'
  gem 'rspec-html-matchers', github: '3scale/rspec-html-matchers', branch: 'fix/rspec-3-with-xml-document', require: false

  gem 'shoulda', '~> 4.0'

  gem 'ci_reporter_shell', github: '3scale/ci_reporter_shell', require: false
  gem 'minitest', '5.10.3'
  gem 'minitest-ci', require: false
  gem 'minitest-reporters', require: false
  gem 'minitest-stub-const'
  gem 'rspec_junit_formatter', require: false

  # IMPORTANT: Load 'mocha' after 'minitest' and 'shoulda'.
  gem 'mocha', require: 'mocha/minitest'

  gem 'database_cleaner', require: false

  # performance tests
  gem "n_plus_one_control"
  gem 'ruby-prof'
  gem 'with_env'

  gem 'pdf-inspector', require: 'pdf/inspector'
end

group :development, :test do
  gem 'active_record_query_trace'

  gem 'bootsnap', '~> 1.16'
  gem 'bullet', '~> 7.1.6'
  gem 'colorize'
  gem 'factory_bot_rails', '~> 6.2'

  gem 'pry-byebug', '>= 3.11.0'
  gem 'pry-doc', '>= 0.8', require: false
  gem 'pry-rails'
  gem 'pry-shell'
  gem 'pry-stack_explorer'

  gem 'unicorn-rails'
end

group :licenses do
  gem 'license_finder', '~> 7.1.0'
end


gem 'developer_portal', path: 'lib/developer_portal'
gem 'unicorn', require: false, group: %i[production]

# NOTE: Use ENV['DB'] only to install oracle dependencies
group :oracle do
  oracle = -> { (ENV['ORACLE'] == '1') || ENV.fetch('DATABASE_URL', ENV['DB'])&.start_with?('oracle') }
  # ENV['NLS_LANG'] ||= 'AMERICAN_AMERICA.AL32UTF8' if oracle
  ENV['NLS_LANG'] ||= 'AMERICAN_AMERICA.UTF8' if oracle
  gem 'activerecord-oracle_enhanced-adapter', '~> 7.1.0', install_if: oracle
  gem 'ruby-oci8', require: false, install_if: oracle
end

gem 'kubeclient'
gem 'nkf'
gem 'pg', '~> 1.3.5'
