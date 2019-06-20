class AddLimitExceededErrorToProxies < ActiveRecord::Migration
  def up
    add_column :proxies, :error_headers_limits_exceeded, :string
    change_column_default :proxies, :error_headers_limits_exceeded, 'text/plain; charset=us-ascii'

    add_column :proxies, :error_status_limits_exceeded, :integer
    change_column_default :proxies, :error_status_limits_exceeded, 429

    add_column :proxies, :error_limits_exceeded, :string
    change_column_default :proxies, :error_limits_exceeded, 'Usage limit exceeded'
  end

  def down
    remove_column :proxies, :error_headers_limits_exceeded
    remove_column :proxies, :error_status_limits_exceeded
    remove_column :proxies, :error_limits_exceeded
  end
end
