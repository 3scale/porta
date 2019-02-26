class CreateOIDCConfigurations < ActiveRecord::Migration
  def change
    create_table :oidc_configurations do |t|
      t.text :config
      t.string :oidc_configurable_type, null: false
      t.integer :oidc_configurable_id, limit: 8, null: false
      t.integer :tenant_id, limit: 8

      t.timestamps null: false
    end
    add_index :oidc_configurations, [:oidc_configurable_type, :oidc_configurable_id], unique: true, name: :oidc_configurable
  end
end
