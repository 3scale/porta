# frozen_string_literal: true

unless System::Database.oracle?
  ActiveRecord::Base.class_eval do
    extend(Module.new do
      def set_date_columns(*)
        # nothing, just nicer than to have a conditional
      end
    end)
  end

  # This is for Rails 4, I do not know if it is needed
  ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "BIGINT(20) auto_increment PRIMARY KEY"

  # Works in rails 5
  ActiveRecord::ConnectionAdapters::MySQL::TableDefinition.prepend(Module.new do
    def new_column_definition(name, type, options)
      column = super
      if type == :primary_key
        column.type = :bigint
        column.unsigned = false
        column.auto_increment = true
      end
      column
    end
  end)
end
