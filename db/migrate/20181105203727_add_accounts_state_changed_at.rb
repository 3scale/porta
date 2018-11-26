# frozen_string_literal: true

class AddAccountsStateChangedAt < ActiveRecord::Migration
  def change
    add_column :accounts, :state_changed_at, :datetime
    add_index :accounts, %i[domain state_changed_at]
    add_index :accounts, %i[self_domain state_changed_at]
    add_index :accounts, %i[state state_changed_at]
  end
end
