# frozen_string_literal: true

# License:
# Copyright (c) 2011-2017 GitLab B.V.
#
# With regard to the GitLab Software:
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# For all third party components incorporated into the GitLab Software, those
# components are licensed under the original license provided by the owner of the
# applicable component.

# Extracted from: https://gitlab.com/gitlab-org/gitlab-ce/blob/4f6620a5ae00383a015379f95408ed7f1be1bdbb/lib/gitlab/testing/request_inspector_middleware.rb

# rubocop:disable Style/ClassVars
module Gitlab
  module Testing
    class RequestInspectorMiddleware
      @@log_requests = Concurrent::AtomicBoolean.new(false)
      @@logged_requests = Concurrent::Array.new
      @@inject_headers = Concurrent::Hash.new

      # Resets the current request log and starts logging requests
      def self.log_requests!(headers = {})
        @@inject_headers.replace(headers)
        @@logged_requests.replace([])
        @@log_requests.value = true
      end

      # Stops logging requests
      def self.stop_logging!
        @@log_requests.value = false
      end

      def self.requests
        @@logged_requests
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless @@log_requests.true?

        url = env['REQUEST_URI']
        env.merge! http_headers_env(@@inject_headers) if @@inject_headers.any?
        request_headers = env_http_headers(env)
        status, headers, body = @app.call(env)

        full_body = +''
        body.each { |b| full_body << b }

        request = OpenStruct.new(
          url: url,
          status_code: status,
          request_headers: request_headers,
          response_headers: headers,
          body: full_body
        )
        log_request request

        [status, headers, body]
      end

      private

      def env_http_headers(env)
        Hash[*env.select { |k, v| k.start_with? 'HTTP_' }
                .collect { |k, v| [k.sub(/^HTTP_/, ''), v] }
                .collect { |k, v| [k.split('_').collect(&:capitalize).join('-'), v] }
                .sort
                .flatten]
      end

      def http_headers_env(headers)
        Hash[*headers
                .collect { |k, v| [k.split('-').collect(&:upcase).join('_'), v] }
                .collect { |k, v| [k.prepend('HTTP_'), v] }
                .flatten]
      end

      def log_request(response)
        @@logged_requests.push(response)
      end
    end
  end
end
# rubocop:enable Style/ClassVars
