# frozen_string_literal: true

module ThreeScale::SpamProtection
  module Checks

    TIMESTAMP_PERIOD = 10.seconds

    class Timestamp < Base

      def input(form)
        output = form.template.text_field_tag :timestamp, encode(timestamp_value), hidden: true
        form.template.tag.li output, class: "hidden"
      end

      def probability(object)
        value = object.params[:timestamp]

        return fail(value) if value.blank?

        begin
          value = Time.zone.at(decode(value)).utc.to_i
          add_to_average(diff_from_now(value))
        rescue StandardError => exception
          Rails.logger.error "[SpamProtection] malformed timestamp #{value}. Error: #{exception} Value: #{value}"
          raise SpamDetectedError # Immediately mark as bot
        end
      end

      private

      def diff_from_now(time)
        current = Time.now.utc.to_i
        diff = current - time
        # linear for now, but would be cool to do exponential growth
        # as in http://en.wikipedia.org/wiki/File:Exponential_pdf.svg
        Rails.logger.info "[SpamProtection] #{name} timestamp diff is #{diff} seconds"
        if diff > TIMESTAMP_PERIOD
          0
        else
          1 - (diff.to_f / TIMESTAMP_PERIOD)
        end
      end

      def timestamp_value
        Time.now.utc.to_i
      end
    end

  end
end
