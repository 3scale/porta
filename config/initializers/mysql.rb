# frozen_string_literal: true

if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
  ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "BIGINT(20) auto_increment PRIMARY KEY"
end

unless System::Database.oracle?
  ActiveRecord::Base.class_eval do
    extend(Module.new do
      def set_date_columns(*)
        # nothing, just nicer than to have a conditional
      end
    end)
  end
end
