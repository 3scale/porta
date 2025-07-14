ENV["RAILS_ENV"] ||= "test"

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'config/boot'

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

require 'minitest/autorun'
if defined?(::Mocha)
  ::Mocha::Integration::MiniTest.activate
else
  require 'mocha/setup'
end

require 'active_support/core_ext'

require 'test_helpers/simple_mini_test'

unless defined?(Rails)
  module Rails
    extend self
    $mocha = Object.new.extend(Mocha::API)

    # this is for pry-rails
    class Railtie
      def self.method_missing(*)
        $mocha.stub_everything
      end
    end

    # this is for other tests
    def logger
      $mocha.stub_everything
    end

    def env
      $mocha.stub_everything(:test? => true)
    end
  end
end
