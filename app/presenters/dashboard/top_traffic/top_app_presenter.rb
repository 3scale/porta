module Dashboard
  module TopTraffic
    class TopAppPresenter < SimpleDelegator
      attr_reader :position

      # @param current_position [Integer]
      # @param previous_position [Integer,nil]
      def initialize(object, current_position, previous_position)
        super(object)
        @change = previous_position - current_position if previous_position
        @position = current_position
      end

      def state
        case (change || Float::INFINITY) <=> 0
        when +1 then :climbing
        when -1 then :falling
        when 0 then  :stable
        else :unknown
        end
      end

      def position_change
        @change
      end

      def title
        if position_change
          "Previous position: #{position_change + position}"
        else
          "Just appeared"
        end
      end

      def change
        change = position_change

        if change.nil?
          'New'
        elsif change == 0
          ''
        elsif change.abs == change # positive change
          "+#{change}"
        else
          "-#{change.abs}"
        end
      end
    end
  end
end

