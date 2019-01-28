# frozen_string_literal: true

module System
  module Database
    class Trigger
      def initialize(table, trigger)
        @table = table
        @name = "#{table}_tenant_id"
        @trigger = trigger
      end

      attr_reader :name, :table

      def drop
        raise NotImplementedError
      end

      def create
        <<~SQL
          CREATE TRIGGER #{name} BEFORE INSERT ON #{table} FOR EACH ROW #{body}
        SQL
      end

      def recreate
        [drop, create]
      end

      protected

      attr_reader :trigger

      def body
        raise NotImplementedError
      end

      def set_master_id
        raise NotImplementedError
      end

      def self.master_id
        # Prevents master id from being fetched multiple times
        @master_id ||= Account.master.id
      end

      delegate :master_id, to: :class
    end
  end
end
