module Liquid
  module Drops
    class I18n < Drops::Base
      allowed_name :i18n

      drop_example %{
        Provide useful strings for i18n support:

        {{ object.some_date | date: i18n.long_date }}

      }

      def initialize
        super
      end

      desc "Alias for `%b %d`."
      example %{
        Dec 11
      }
      def short_date
        '%b %d'
      end

      desc "Alias for `%B %d, %Y`."
      example %{
        December 11, 2013
      }
      def long_date
        '%B %d, %Y'
      end

      desc "Alias for `%Y-%m-%d`."
      example %{
        2013-12-11
      }
      def default_date
        '%Y-%m-%d'
      end

      desc "Alias for `%d %b %Y %H:%M:%S %Z`."
      example %{
        "16 Mar 2017 16:45:21 UTC"
      }
      def default_time
        ::I18n.t(:'time.formats.default')
      end
    end
  end
end
