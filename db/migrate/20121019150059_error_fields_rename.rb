class ErrorFieldsRename < ActiveRecord::Migration
  def self.up
    rename_column :proxies, :over_limit_status, :error_status_over_limit
    rename_column :proxies, :over_limit_headers, :error_headers_over_limit

    rename_column :proxies, :auth_failed_status, :error_status_auth_failed
    rename_column :proxies, :auth_failed_headers,  :error_headers_auth_failed

    rename_column :proxies, :auth_missing_status, :error_status_auth_missing
    rename_column :proxies, :auth_missing_headers, :error_headers_auth_missing

    rename_column :proxies, :no_match_status, :error_status_no_match
    rename_column :proxies, :no_match_headers, :error_headers_no_match
  end

  def self.down
  end
end
