class CreateBackendApis < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    create_table :backend_apis do |table|
      t.string :name, null: false, limit: 511
      t.string :system_name, unique: true, null: false
      t.text :description
      t.string :private_endpoint

      t.belongs_to :account, limit: 8

      t.timestamps null: false
      t.integer :tenant_id, limit: 8
      t.index [:account_id, :system_name], unique: true
    end

    create_table :backend_api_configs do |t|
      t.string :path, null: false, default: ''

      t.belongs_to :service, limit: 8
      t.belongs_to :backend_api, limit: 8

      t.timestamps null: false
      t.integer :tenant_id, limit: 8

      t.index :service_id
      t.index [:path, :service_id], unique: true
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
