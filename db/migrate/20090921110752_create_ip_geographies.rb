class CreateIpGeographies < ActiveRecord::Migration
  def self.up
    create_table :ip_geographies do |t|
      t.integer :client_ip,          :null => false, :limit => 4
      t.string :client_host_name,    :null => true
      t.string :client_lng,          :null => true
      t.string :client_lat,          :null => true
      t.string :client_country_code, :null => true
      t.string :client_state,        :null => true
      t.string :client_city,         :null => true
      t.timestamps
    end
    add_index :ip_geographies, :client_ip
  end

  def self.down
    drop_table :ip_geographies
  end
end
