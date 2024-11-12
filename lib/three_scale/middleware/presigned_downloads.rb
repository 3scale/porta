# frozen_string_literal: true

module ThreeScale
  module Middleware
    class PresignedDownloads
      RE_SEPARATOR = ::File::SEPARATOR == "/" ? "/" : "[#{Regexp.escape(::File::SEPARATOR)}/]"
      TIMESTAMP_FORMAT = "%Y%m%dT%H%M%S%Z"
      PAST_TIME = Time.new(1970)

      private_constant :PAST_TIME

      delegate *%i[requires_signing? good_signature? signature_at to_time], to: :class, private: true

      class << self
        def verifier
          Rails.application.message_verifier("file downloads")
        end

        def requires_signing?(path)
          # for the used separator see https://github.com/rack/rack/pull/2257
          # question mark on first separator is paranoia of getting a relative path somehow
          invoices_re = /#{RE_SEPARATOR}?system#{RE_SEPARATOR}.*#{RE_SEPARATOR}invoices#{RE_SEPARATOR}/
          path.start_with? invoices_re
        end

        def sign_path_if_needed(path, expires_in = 3600)
          requires_signing?(path) ? sign(path, expires_in) : path
        end

        def sign(path, expires_in = 3600)
          sign_at(path, Time.now.utc.round + expires_in)
        end

        def sign_at(path, expires_at)
          expires_timestamp = expires_at.strftime(TIMESTAMP_FORMAT)
          signature = signature_at(path, expires_at)
          params = { "3scale-Expires" => expires_timestamp, "3scale-Signature" => signature }.to_param

          "#{path}?#{params}"
        end

        def signature_at(path, expires_at)
          signing_options = { purpose: :download, expires_at: }
          verifier.generate(path.b, **signing_options).split("--").last
        end

        def to_time(timestamp)
          Time.strptime(timestamp, TIMESTAMP_FORMAT) rescue PAST_TIME
        end
      end

      def initialize(app)
        @app = app
        @file_handler = find_file_handler(app)
      end

      def call(env)
        path = @file_handler.send(:clean_path, env["PATH_INFO"])

        return [403, {}, ["Forbidden"]] if path && requires_signing?(path) && !good_signature?(env)

        @app.call(env)
      end

      private

      def good_signature?(env)
        params = Rack::Utils.parse_query(env["QUERY_STRING"])
        return false if params["3scale-Expires"].blank? || params["3scale-Signature"].blank?

        expires_at = to_time(params["3scale-Expires"])
        return false if expires_at < Time.now

        params["3scale-Signature"] == signature_at(env["PATH_INFO"], expires_at)
      end

      def find_static_middleware(app)
        raise "cannot find ActionDispatch::Static middleware in the chain" unless app
        app.is_a?(ActionDispatch::Static) ? app : find_static_middleware(app.instance_variable_get("@app"))
      end

      def find_file_handler(app)
        find_static_middleware(app).instance_variable_get("@file_handler") || \
          raise("cannot find file handler")
      end
    end
  end
end
