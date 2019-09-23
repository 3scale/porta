class CreateGatewayConfigurations < ActiveRecord::Migration
  def change
    create_table :gateway_configurations do |t|
      t.text :settings
      t.belongs_to :proxy, limit: 8
      t.integer :tenant_id, limit: 8

      t.timestamps null: false
    end
    add_index :gateway_configurations, [:proxy_id], unique: true
  end
end
