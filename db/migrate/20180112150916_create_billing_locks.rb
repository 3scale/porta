class CreateBillingLocks < ActiveRecord::Migration
  def self.up
    create_table(:billing_locks, id: false) do |t|
      t.column :account_id, :integer, limit: 8, null: false
      t.datetime :created_at, null: false
    end
    execute 'ALTER TABLE billing_locks ADD PRIMARY KEY (account_id);'
  end

  def self.down
    drop_table :billing_locks
  end
end
