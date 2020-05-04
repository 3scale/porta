# frozen_string_literal: true

module ThreeScale
  module Middleware
    class DevDomain
      PREVIEW_HOST = /\.preview\d+\./
      REPLACEMENT = '.'

      attr_reader :pattern, :replacement

      def initialize(app, pattern = nil, replacement = nil)
        @app = app
        @pattern = Regexp.compile(pattern.presence  || PREVIEW_HOST)
        @replacement = replacement.presence || REPLACEMENT
        freeze
      end

      def call(env)
        host = env['HTTP_HOST']
        env['HTTP_X_FORWARDED_FOR_DOMAIN'] = host

        new_host = case host
                   when pattern then replace_host!(env, host)
                   else host
                   end

        status, headers, = response = @app.call(env)

        case status
        when 300..400
          location = headers.fetch('Location') { return response }
          headers['Location'] = location.sub(new_host, host)
        end

        response
      end

      protected

      def replace_host!(env, host)
        new_host = host.sub(pattern, @replacement).sub(/\.$/, '.')
        forwarded_for = env['HTTP_X_FORWARDED_HOST']

        env['HTTP_HOST'] = new_host
        env['HTTP_X_FORWARDED_HOST'] = [
          forwarded_for,
          new_host
        ].compact.join(',')

        new_host
      end
    end

  end
end
