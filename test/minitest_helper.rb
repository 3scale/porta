require_relative 'test_helper.rb'
require 'test_helpers/simple_mini_test'

raise "RSpec should not be loaded" if defined?(RSpec)

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
