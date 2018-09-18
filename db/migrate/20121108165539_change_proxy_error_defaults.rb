class ChangeProxyErrorDefaults < ActiveRecord::Migration
  def self.up
    change_column :proxies, :error_headers_no_match, :string, :default => "text/plain; charset=us-ascii", :null => false
    change_column :proxies, :error_headers_auth_failed, :string, :default => "text/plain; charset=us-ascii", :null => false
    change_column :proxies, :error_headers_auth_missing, :string, :default => "text/plain; charset=us-ascii", :null => false
    change_column :proxies, :error_headers_over_limit, :string, :default => "text/plain; charset=us-ascii", :null => false
  end

  def self.down
  end
end
