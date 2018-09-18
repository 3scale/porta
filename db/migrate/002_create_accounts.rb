class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.column :id, :int, :null => false, :autoincrement => true
      t.column :user_id, :int, :null => false
      t.column :acc_type, :string, :default => "buyer"
      t.column :org_name, :string, :default => '(set your org name / under account)'
      t.column :org_legaladdress, :string, :default => '(set your org address / under account)'
      t.column :viewstatus, :string, :default => 'PRIVATE'
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    execute "SET FOREIGN_KEY_CHECKS=0"
    drop_table :accounts
    execute "SET FOREIGN_KEY_CHECKS=1"
  end
end
