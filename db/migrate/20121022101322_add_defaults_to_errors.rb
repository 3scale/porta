class AddDefaultsToErrors < ActiveRecord::Migration
  def self.up
    change_column :proxies, :error_no_match, :string, :default => 'No rule matched', :null => false
    change_column :proxies, :error_headers_no_match, :string, :default => "Content-type: text/plain charset=us-ascii", :null => false
  end

  def self.down
    change_column :proxies, :error_no_match, :string, :default => '', :null => false
    change_column :proxies, :error_headers_no_match, :string, :default => '', :null => false
  end
end
