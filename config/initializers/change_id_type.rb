# frozen_string_literal: true

# Remove this file when upgraded to 5.1
module PrimaryKeyBigInt
  def new_column_definition(name, type, options)
    column = super
    if type == :primary_key
      column.type = :bigint
      column.unsigned = false
      column.auto_increment = true
    end
    column
  end
end

ActiveSupport.on_load(:active_record) do
  # This is for Rails 4, I do not know if it is needed
  ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = 'bigint(20) auto_increment PRIMARY KEY'
  # Works in rails 5
  ActiveRecord::ConnectionAdapters::MySQL::TableDefinition.prepend PrimaryKeyBigInt
end
