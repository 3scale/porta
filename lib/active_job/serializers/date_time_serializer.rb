# frozen_string_literal: true

require 'active_job/serializers/time_object_serializer'

module ActiveJob
  module Serializers
    class DateTimeSerializer < TimeObjectSerializer # :nodoc:
      def deserialize(hash)
        DateTime.iso8601(hash["value"])
      end

      private
        def klass
          DateTime
        end
    end
  end
end
