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

# Extracted from: https://gitlab.com/gitlab-org/gitlab-ce/blob/4f6620a5ae00383a015379f95408ed7f1be1bdbb/lib/gitlab/testing/request_blocker_middleware.rb

# rubocop:disable Style/ClassVars
module Gitlab
  module Testing
    class RequestBlockerMiddleware
      @@num_active_requests = Concurrent::AtomicFixnum.new(0)
      @@block_requests = Concurrent::AtomicBoolean.new(false)
      @@slow_requests = Concurrent::AtomicBoolean.new(false)

      # Returns the number of requests the server is currently processing.
      def self.num_active_requests
        @@num_active_requests.value
      end

      # Prevents the server from accepting new requests. Any new requests will return an HTTP
      # 503 status.
      def self.block_requests!
        @@block_requests.value = true
      end

      # Slows down incoming requests (useful for race conditions).
      def self.slow_requests!
        @@slow_requests.value = true
      end

      # Allows the server to accept requests again.
      def self.allow_requests!
        @@block_requests.value = false
        @@slow_requests.value = false
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        increment_active_requests

        if block_requests?
          block_request(env)
        else
          sleep 0.2 if slow_requests?
          @app.call(env)
        end
      ensure
        decrement_active_requests
      end

      private

      def block_requests?
        @@block_requests.true?
      end

      def slow_requests?
        @@slow_requests.true?
      end

      def block_request(env)
        [503, {}, []]
      end

      def increment_active_requests
        @@num_active_requests.increment
      end

      def decrement_active_requests
        @@num_active_requests.decrement
      end
    end
  end
end

# rubocop:enable Style/ClassVars
