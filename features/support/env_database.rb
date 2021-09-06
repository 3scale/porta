# frozen_string_literal: true

require 'database_cleaner/cucumber'
non_transactional = %w[
  @backend
  @emails
  @stats
  @audit
  @commit-transactions
].freeze

transactional = non_transactional.map {|t| "not #{t}" }

Before transactional.join(' or ') do
  Cucumber::Rails::Database.javascript_strategy = :transaction
  Cucumber::Rails::Database.before_js if Cucumber::Rails::Database.autorun_database_cleaner
end

Before non_transactional.join(' or ') do
  Cucumber::Rails::Database.javascript_strategy = :truncation
  Cucumber::Rails::Database.before_non_js if Cucumber::Rails::Database.autorun_database_cleaner
end
