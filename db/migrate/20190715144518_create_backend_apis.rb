class CreateBackendApis < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    create_table :backend_apis do |t|
      t.string :name, null: false
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

      t.index [:path, :service_id], unique: true
    end
  end
end
