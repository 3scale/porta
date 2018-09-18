module Liquid
  module Drops
    class TimeZone < Drops::Base

      def initialize(timezone)
        @timezone = timezone
      end

      def full_name
        ActiveSupport::TimeZone.new(@timezone).to_s
      end

      def to_str
        @timezone
      end

      def identifier
        ActiveSupport::TimeZone.new(@timezone).tzinfo.name
      end

    end

  end
end
