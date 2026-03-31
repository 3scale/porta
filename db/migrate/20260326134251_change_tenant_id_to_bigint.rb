# frozen_string_literal: true

class ChangeTenantIdToBigint < ActiveRecord::Migration[7.1]
  disable_ddl_transaction! if System::Database.postgres?

  def up
    return if System::Database.oracle?

    safety_assured do
      change_column :annotations, :tenant_id, :bigint
      change_column :countries, :tenant_id, :bigint
      change_column :system_operations, :tenant_id, :bigint
    end
  end
end
