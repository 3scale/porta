# frozen_string_literal: true

class CreateBackendApis < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    create_table :backend_apis do |table|
      table.string :name, null: false, limit: 511
      table.string :system_name, unique: true, null: false
      table.text :description
      table.string :private_endpoint

      table.belongs_to :account, limit: 8

      table.timestamps null: false
      table.integer :tenant_id, limit: 8
      table.index %i[account_id system_name], unique: true
    end

    create_table :backend_api_configs do |table|
      table.string :path, default: ''

      table.belongs_to :service, limit: 8
      table.belongs_to :backend_api, limit: 8

      table.timestamps null: false
      table.integer :tenant_id, limit: 8

      table.index :service_id
      table.index %i[path service_id], unique: true
    end

    return unless System::Database.mysql?

    safety_assured do
      [:backend_apis, :backend_api_configs].each do |table_name|
        execute "ALTER TABLE #{table_name} CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
      end
    end
  end

  def down
    drop_table :backend_api_configs
    drop_table :backend_apis
  end
end
