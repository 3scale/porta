class AddStateToBackendApis < ActiveRecord::Migration
  disable_ddl_transaction! if System::Database.postgres?

  def change
    safety_assured { add_column :backend_apis, :state, :string, default: :published, null: false }
    add_index :backend_apis, :state, System::Database.postgres? ? { algorithm: :concurrently } : {}
  end
end
