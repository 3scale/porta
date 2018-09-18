module Liquid
  module Drops
    class Today < Drops::Base

      allowed_name :today

      def initialize(date = Date.today)
        @date = date
      end

      desc "Returns current month (1-12)."
      def month
        @date.month
      end

      desc "Returns current day of the month (1-31)."
      def day
        @date.day
      end

      desc "Returns current year."
      example "Create dynamic copyright", %{
        <span class="copyright">&copy;{{ today.year }}</span>
      }
      def year
        @date.year
      end

      desc "Returns the date of beginning of current month."
      example %q{
        This month began on {{ today.beginning_of_month | date: '%A' }}
      }
      def beginning_of_month
        @date.beginning_of_month
      end

      hidden

      def strftime(format)
        @date.strftime(format)
      end
    end
  end
end
