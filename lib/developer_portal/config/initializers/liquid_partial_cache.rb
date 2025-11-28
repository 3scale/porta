# frozen_string_literal: true

# Patch Liquid::PartialCache to support context-aware file systems
# This is needed because Liquid 5.x removed context parameter from FileSystem#read_template_file
# (see https://github.com/Shopify/liquid/pull/441),
# but our CMS::DatabaseFileSystem needs access to context.registers[:draft]
module Liquid
  class PartialCache
    class << self
      alias_method :load_without_context_injection, :load

      def load(template_name, context:, parse_context:)
        file_system = context.registers[:file_system]

        # Inject context into file system if it supports it
        file_system.current_context = context if file_system.respond_to?(:current_context=)

        load_without_context_injection(template_name, context: context, parse_context: parse_context)
      ensure
        # Clean up context reference to avoid memory leaks
        file_system.current_context = nil if file_system.respond_to?(:current_context=)
      end
    end
  end
end
