class RemoveClientPrefixFromColumnsInIpGeographies < ActiveRecord::Migration
  def self.up
    change_table :ip_geographies do |table|
      table.rename :client_host_name, :host_name
      table.rename :client_lng, :lng
      table.rename :client_lat, :lat
      table.rename :client_country_code, :country_code
      table.rename :client_state, :state
      table.rename :client_city, :city
      table.rename :client_ip, :ip
    end
  end

  def self.down
    change_table :ip_geographies do |table|
      table.rename :host_name, :client_host_name
      table.rename :lng, :client_lng
      table.rename :lat, :client_lat
      table.rename :country_code, :client_country_code
      table.rename :state, :client_state
      table.rename :city, :client_city
      table.rename :ip, :client_ip
    end
  end
end
