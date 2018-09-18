class CreateProxyRules < ActiveRecord::Migration
  def self.up
    create_table :proxy_rules do |t|
      t.integer :proxy_id, :limit => 8
      t.string  :http_method
      t.string  :pattern
      t.integer :metric_id, :limit => 8
      t.string  :metric_system_name
      t.integer :delta
      t.integer :tenant_id, :limit => 8

      t.timestamps
    end
  end

  def self.down
    drop_table :proxy_rules
  end
end
