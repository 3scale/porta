# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  if System::Database.mysql?
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
end
