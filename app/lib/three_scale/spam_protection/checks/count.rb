module ThreeScale::SpamProtection
  module Checks

    COUNT_ATTEMPTS = 3
    COUNT_PERIOD = 1.minute

    class Count < Base

      def initialize(store)
        super
        @store_count = store['count']
        @store_count['period_start'] ||= Time.now.utc.to_i
        @store_count['count_diff'] ||= COUNT_ATTEMPTS
      end

      def probability(_object)
        update_diffs

        case @store_count['count_diff']
        when 1..COUNT_ATTEMPTS # Attempts left
          add_to_average(0)
        else
          raise SpamCheckError # No attempts left, mark as bot
        end
      end

      private

      def update_diffs
        count = [@store_count['count_diff'] - 1, 0].max
        current = Time.now.utc.to_i
        diff = current - @store_count['period_start']
        if diff > COUNT_PERIOD # After a PERIOD, check is reset
          @store_count['period_start'] = current
          @store_count['count_diff'] = COUNT_ATTEMPTS
        else # Within a PERIOD, count attempts
          @store_count['count_diff'] = count
        end
      end
    end

  end
end
