class AddCustomStatusErrorsToProxies < ActiveRecord::Migration
  def self.up
    add_column :proxies, :over_limit_status, :integer, :default => 409, :null => false
    add_column :proxies, :over_limit_headers, :string, :default => "Content-type: text/plain charset=us-ascii", :null => false

    add_column :proxies, :auth_failed_status, :integer, :default => 403, :null => false
    add_column :proxies, :auth_failed_headers, :string, :default => "Content-type: text/plain charset=us-ascii", :null => false

    add_column :proxies, :auth_missing_status, :integer, :default => 403, :null => false
    add_column :proxies, :auth_missing_headers, :string, :default => "Content-type: text/plain charset=us-ascii", :null => false

    add_column :proxies, :error_no_match, :string, :default => '', :null => false
    add_column :proxies, :no_match_status, :integer, :default => 404, :null => false
    add_column :proxies, :no_match_headers, :string, :default => '', :null => false
  end

  def self.down
    remove_column :proxies, :auth_failed_headers
    remove_column :proxies, :auth_missing_headers
    remove_column :proxies, :over_limit_headers
    remove_column :proxies, :auth_missing_status
    remove_column :proxies, :auth_failed_status
    remove_column :proxies, :over_limit_status
    remove_column :proxies, :error_no_match
    remove_column :proxies, :no_match_status
    remove_column :proxies, :no_match_headers
  end
end
