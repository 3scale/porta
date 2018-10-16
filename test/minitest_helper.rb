ENV["RAILS_ENV"] ||= "test"

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'config/boot'

require 'simplecov'
SimpleCov.start

if ENV['CI']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'minitest/autorun'
if defined?(::Mocha)
  require 'mocha/integration/mini_test'
  # This will be in upcomming versions of mocha
  # ::Mocha::Integration::MiniTest.activate
else
  require 'mocha/setup'
end

require 'active_support/core_ext'

require 'config/initializers/ruby1.9.rb'

unless defined?(Rails)
  module Rails extend self
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
