# frozen_string_literal: true

class FixOracleConstraintsReferencesToIndexNames < ActiveRecord::Migration
  def up
    return unless System::Database.oracle?

    db_connection = ActiveRecord::Base.connection
    constraints_to_be_changed = [
      {constraint_name: 'INDEX_ACCOUNTS_ON_DOMAIN',      column_name: 'DOMAIN',      table_name: 'ACCOUNTS', index_name: 'INDEX_ACCOUNTS_ON_DOMAIN_AND_DELETED_AT'},
      {constraint_name: 'INDEX_ACCOUNTS_ON_SELF_DOMAIN', column_name: 'SELF_DOMAIN', table_name: 'ACCOUNTS', index_name: 'INDEX_ACCOUNTS_ON_SELF_DOMAIN_AND_DELETED_AT'}
    ]
    constraints_to_be_changed.each do |constraint_data|
      constraint_name, table_name = constraint_data.values_at(:constraint_name, :table_name)
      db_connection.execute("ALTER TABLE #{table_name} DROP CONSTRAINT #{constraint_name}")
      db_connection.execute("ALTER TABLE #{table_name} ADD  CONSTRAINT #{constraint_name} UNIQUE (#{constraint_data[:column_name]}) USING INDEX #{constraint_name}")
    end
  end

  def down; end
end
