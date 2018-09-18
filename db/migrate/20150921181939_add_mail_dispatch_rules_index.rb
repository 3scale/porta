class AddMailDispatchRulesIndex < ActiveRecord::Migration
  def change
    add_index :mail_dispatch_rules, [:system_operation_id, :account_id], unique: true
  end
end
