# frozen_string_literal: true

module ThreeScale
  module Middleware
    class HandleParseError
      def initialize(app)
        @app = app
      end

      attr_reader :app

      def call(env)
        app.call(env)
      # TODO: In Rails 5.1, replace this error class for ActionDispatch::Http::Parameters::ParseError
      # https://github.com/rails/rails/blob/ce93740a5e4437dfc1cf9b0b13da1bad06a2a598/actionpack/lib/action_dispatch/http/parameters.rb#L125
      rescue ActionDispatch::ParamsParser::ParseError => error
        status = 422
        Rails.logger.error("Handling Exception: '#{error.class}' with status #{status}")
        [status, {}, [nil]]
      end
    end
  end
end
