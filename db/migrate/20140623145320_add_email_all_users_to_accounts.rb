class AddEmailAllUsersToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :email_all_users, :boolean, default: false
  end
end
