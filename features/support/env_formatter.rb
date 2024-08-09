# frozen_string_literal: true

if ENV['CI']
  require 'simplecov'
  require "simplecov_json_formatter"
  require 'simplecov-cobertura'
  formatters = [
    SimpleCov::Formatter::SimpleFormatter,
    SimpleCov::Formatter::JSONFormatter,
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CoberturaFormatter
  ]
  SimpleCov.start do
    formatter SimpleCov::Formatter::MultiFormatter.new(formatters)
  end
end

require 'cucumber/formatter/unicode' # Remove this line if you don't want Cucumber Unicode support
