module Dashboard
  module TopTraffic
    class LeftAppPresenter < SimpleDelegator
      attr_reader :position

      def state
        :left
      end

      def change
        'Out'
      end

      def title
        'Appeared in previous period, but not this one'.freeze
      end
    end
  end
end
