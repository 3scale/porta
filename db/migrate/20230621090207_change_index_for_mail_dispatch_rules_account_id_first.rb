class ChangeIndexForMailDispatchRulesAccountIdFirst < ActiveRecord::Migration[5.2]
  disable_ddl_transaction! if System::Database.postgres?

  def up
    add_index :mail_dispatch_rules, [:account_id, :system_operation_id], index_options
    remove_index :mail_dispatch_rules, column: [:system_operation_id, :account_id]
  end

  def down
    add_index :mail_dispatch_rules, [:system_operation_id, :account_id], index_options
    remove_index :mail_dispatch_rules, column: [:account_id, :system_operation_id]
  end

  private

  def index_options
    index_options = { unique: true }
    index_options[:algorithm] = :concurrently if System::Database.postgres?
    index_options
  end
end
