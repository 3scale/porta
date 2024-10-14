# frozen_string_literal: true

module ThreeScale
  module Patterns
    # because of https://github.com/Selleo/pattern/issues/39, this is a modification of
    # https://github.com/Selleo/pattern/blob/1272f18e71d9cb2dcad03c2b6e9c950313b0a365/lib/patterns/service.rb
    class Service
      attr_reader :result

      class << self
        def call(...)
          new(...).tap do |service|
            service.instance_variable_set(
              "@result",
              service.call
            )
          end
        end
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
