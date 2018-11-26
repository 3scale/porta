# frozen_string_literal: true

class AddFirstAdminIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :first_admin_id, :integer, limit: 8
  end
end
