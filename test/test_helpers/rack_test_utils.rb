require 'rack/test/utils'

# Reopen Rack::Test::Utils to fix a bug https://github.com/rack-test/rack-test/commit/ece681de8ffee9d0caff30e9b93f882cc58f14cb
# TODO: Remove when migrating to Rails 5.1+

module Rack
  module Test
    module Utils
      def build_nested_query(value, prefix = nil)
        case value
          when Array
            if value.empty?
              "#{prefix}[]="
            else
              value.map do |v|
                unless unescape(prefix) =~ /\[\]$/
                  prefix = "#{prefix}[]"
                end
                build_nested_query(v, "#{prefix}")
              end.join("&")
            end
          when Hash
            value.map do |k, v|
              build_nested_query(v, prefix ? "#{prefix}[#{escape(k)}]" : escape(k))
            end.join("&")
          when NilClass
            prefix.to_s
          else
            "#{prefix}=#{escape(value)}"
        end
      end

    end
  end
end
