module Liquid
  module Drops
    class ReferrerFilter < Drops::Base

      allowed_names :referrer_filter, :referrer_filters

      def initialize(referrer_filter)
        @filter = referrer_filter
      end

      def id
        @filter.id
      end

      def value
        @filter.value
      end

      def delete_url
        admin_application_referrer_filter_path(@filter.application, @filter.id)
      end

      def application
        Drops::Application.new(@filter.application)
      end
    end
  end
end
