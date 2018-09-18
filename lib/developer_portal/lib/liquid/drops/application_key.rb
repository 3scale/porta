module Liquid
  module Drops
    class ApplicationKey < Drops::Base

      allowed_names :application_key, :application_keys

      def initialize(application_key)
        @application_key = application_key
      end

      def id
        @application_key.id
      end

      def value
        @application_key.value
      end

      def url
        admin_application_key_path(@application_key.application, @application_key.value)
      end

      def application
        Drops::Application.new(@application_key.application)
      end
    end
  end
end
