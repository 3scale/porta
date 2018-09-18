class AddStateToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :state, :string, :default => "pending"
    add_index :accounts,  :state, :name => "idx_state"

    execute('UPDATE accounts SET state = "approved"')
  end

  def self.down
    remove_column :accounts, :state
  end
end

