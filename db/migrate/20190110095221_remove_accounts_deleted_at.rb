# frozen_string_literal: true

class RemoveAccountsDeletedAt < ActiveRecord::Migration
  def change
    remove_index :accounts, %i[state deleted_at]
    remove_index :accounts, %i[self_domain deleted_at]
    remove_index :accounts, %i[domain deleted_at]
    remove_column :accounts, :deleted_at
  end
end
