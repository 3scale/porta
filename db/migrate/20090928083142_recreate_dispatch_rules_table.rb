class RecreateDispatchRulesTable < ActiveRecord::Migration
  def self.up
    if MailDispatchRule.table_exists?
      drop_table :mail_dispatch_rules
    end
    
    create_table :mail_dispatch_rules do |t|
      t.references :account, :system_operation
      t.text :emails
      t.boolean :dispatch, :default => true
      t.timestamps
    end
        
  end

  def self.down
    drop_table :mail_dispatch_rules
  end
end
