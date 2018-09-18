class RemoveErrorOverLimitFromProxy < ActiveRecord::Migration
  def up
    remove_column :proxies, :error_over_limit
    remove_column :proxies, :error_headers_over_limit
    remove_column :proxies, :error_status_over_limit
  end

  def down
    add_column :proxies, :error_status_over_limit, :string
    add_column :proxies, :error_headers_over_limit, :string
    add_column :proxies, :error_over_limit, :string
  end
end
