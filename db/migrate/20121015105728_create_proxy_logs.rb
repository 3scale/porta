class CreateProxyLogs < ActiveRecord::Migration
  def self.up
    create_table :proxy_logs do |t|
      t.integer :provider_id, :limit => 8
      t.integer :tenant_id, :limit => 8
      t.text :lua_file
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :proxy_logs
  end
end
