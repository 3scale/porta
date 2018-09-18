class ChangeIpGeographiesClientIpField < ActiveRecord::Migration
  def self.up
    add_column :ip_geographies, :client_ip_str, :string, :limit => 15
    
    IPGeography.all.each do |ip|
      ip.update_attribute(:client_ip_str, IPAddr.new(ip.client_ip,Socket::AF_INET).to_s)
    end
        
    remove_index :ip_geographies, :client_ip
    remove_column :ip_geographies, :client_ip
    rename_column :ip_geographies, :client_ip_str, :client_ip
    add_index :ip_geographies, :client_ip
  end

  def self.down
    # no way back
  end
end
