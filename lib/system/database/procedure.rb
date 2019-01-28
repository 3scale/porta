# frozen_string_literal: true

module System
  module Database
    class Procedure
      def initialize(name, body, params = {})
        @name = name
        @body = body
        @params = params
      end

      attr_reader :name, :params

      def drop
        raise NotImplementedError
      end

      def create
        raise NotImplementedError
      end

      def recreate
        [drop, create]
      end

      protected

      attr_reader :body

      def params_declaration
        pairs = params.map { |name, type| "#{name} #{type}" }
        "(#{pairs.join(', ')})"
      end

      def signature
        [name, params_declaration].join
      end
    end
  end
end
