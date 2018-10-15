# frozen_string_literal: true

require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    class List
      include Formatter::Io

      def initialize(runtime, path_or_io, options)
        @io = ensure_io(path_or_io)
        @test_locations = []
        @options = options
      end

      def done
        @io.puts files
      end

      %i[before_test_case before_test_step after_test_case after_test_step].each do |method|
        define_method(method) { |*| }
      end

      def before_test_case(test_case)
        test_locations << test_case.location
      end

      private
      attr_reader :test_locations

      def files
        test_locations.map(&:file).uniq
      end
    end
  end
end
