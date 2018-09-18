class CreateProviderConstraints < ActiveRecord::Migration
  def change
    create_table :provider_constraints do |t|
      t.integer :tenant_id, :limit => 8
      t.integer :provider_id, :limit => 8
      t.integer :max_users
      t.integer :max_services

      t.timestamps
    end

    add_index :provider_constraints, :provider_id, unique: true

  end
end
