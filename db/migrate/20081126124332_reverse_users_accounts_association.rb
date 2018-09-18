class ReverseUsersAccountsAssociation < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.references :account
    end

    execute('UPDATE users, accounts
             SET users.account_id = accounts.id
             WHERE users.id = accounts.user_id')

    change_table :accounts do |t|
      t.remove_references :user
    end
  end

  def self.down
    change_table :accounts do |t|
      t.references :user
    end

    execute('UPDATE accounts, users
             SET accounts.user_id = users.id
             WHERE accounts.id = users.account_id')

    change_table :users do |t|
      t.remove_references :account
    end
  end
end
