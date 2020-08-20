# frozen_string_literal: true

require "system/database/#{System::Database.adapter}"

class RemoveAccountColumns < ActiveRecord::Migration[5.0]
  def up
    remove_deleted_at_indexes if deleted_at_column_exists?
    remove_account_columns
  end

  def columns
    %w[payment_gateway_type payment_gateway_options service_preffix first_admin_id].tap do |cols|
      cols << 'deleted_at' if deleted_at_column_exists?
    end
  end

  def deleted_at_column_exists?
    return @deleted_at_column_exists if instance_variable_defined?(:@deleted_at_column_exists)

    @deleted_at_column_exists = column_exists?(:accounts, :deleted_at)
  end

  def remove_deleted_at_indexes
    [
      %i[state deleted_at],
      %i[self_domain deleted_at],
      %i[domain deleted_at]
    ].each do |index_columns|
      remove_index(:accounts, index_columns) if index_exists?(:accounts, index_columns)
    end
  end

  def remove_account_columns
    sql_remove_columns = if System::Database.oracle?
                           "ALTER TABLE accounts DROP (#{columns.join(', ')})"
                         else
                           columns.inject("ALTER TABLE accounts") { |sql, column| sql + "\nDROP COLUMN #{column}," }.chomp(',') + ';'
    end
    safety_assured { execute sql_remove_columns }
  end
end
