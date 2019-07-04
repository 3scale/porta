# frozen_string_literal: true

module EventStore
  class EventRecordBase < RailsEventStoreActiveRecord::Event
    sifter :concat do |*values|
      case System::Database.adapter.to_sym
      when :mysql
        func(:concat, *values)
      else
        values.map { |value| ActiveRecord::Base.connection.visitor.accept(value, Arel::Collectors::SQLString.new).value }.join('||')
      end
    end
  end
end
