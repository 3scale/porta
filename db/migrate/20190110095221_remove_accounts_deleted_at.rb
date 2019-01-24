# frozen_string_literal: true

class RemoveAccountsDeletedAt < ActiveRecord::Migration
  def change
    # This is because the column does not exist in this commit https://github.com/3scale/porta/pull/376/files#diff-8e80045dda54d0771c396e0e8a2c76d2R32
    return if System::Database.postgres?
    remove_index :accounts, %i[state deleted_at]
    remove_index :accounts, %i[self_domain deleted_at]
    remove_index :accounts, %i[domain deleted_at]
    remove_column :accounts, :deleted_at
  end
end
