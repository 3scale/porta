module ThreeScale
  module Middleware
    class DevDomain
      PREVIEW_HOST = /\.preview\d+\./
      REPLACEMENT = '.'.freeze

      attr_reader :pattern, :replacement

      def initialize(app, pattern = nil, replacement = nil)
        @app = app
        @pattern = Regexp.compile(pattern.presence  || PREVIEW_HOST)
        @replacement = replacement.presence || REPLACEMENT
        freeze
      end

      def call(env)
        host = env['HTTP_HOST'.freeze]
        env['HTTP_X_FORWARDED_FOR_DOMAIN'.freeze] = host

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
        new_host = host.sub(pattern, @replacement).sub(/\.$/, '.'.freeze)
        forwarded_for = env['HTTP_X_FORWARDED_HOST'.freeze]

        env['HTTP_HOST'.freeze] = new_host
        env['HTTP_X_FORWARDED_HOST'.freeze] = [
          forwarded_for,
          new_host
        ].compact.join(',')

        new_host
      end
    end

  end
end
