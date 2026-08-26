# frozen_string_literal: true

class CreateAccountSettings < ActiveRecord::Migration[7.1]
  disable_ddl_transaction! if System::Database.postgres?

  def change
    text_opts = { null: false }
    if System::Database.mysql?
      options = "CHARSET=utf8mb4 COLLATE=utf8mb4_bin"
      text_opts[:size] = :medium
    end

    create_table :account_settings, options: options do |t|
      t.bigint :account_id, null: false
      t.string :type, null: false
      t.text :value, **text_opts
      t.bigint :tenant_id
      t.timestamps
    end

    add_index :account_settings, [:account_id, :type], unique: true, name: 'index_account_settings_on_account_id_and_type'

    reversible do |dir|
      dir.up do
        account_settings_triggers = System::Database.triggers.select { |trigger| trigger.table == 'account_settings' }
        AccountSetting.transaction do
          account_settings_triggers.each do |trigger|
            methods = [trigger.create].flatten
            methods.each(&ActiveRecord::Base.connection.method(:execute))
          end
        end
      end
    end
  end
end
