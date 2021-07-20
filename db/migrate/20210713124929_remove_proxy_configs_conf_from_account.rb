class RemoveProxyConfigsConfFromAccount < ActiveRecord::Migration[5.0]
  def change
    safety_assured { remove_column :accounts, :proxy_configs_file_name }
    safety_assured { remove_column :accounts, :proxy_configs_content_type }
    safety_assured { remove_column :accounts, :proxy_configs_file_size }
    safety_assured { remove_column :accounts, :proxy_configs_updated_at }
    safety_assured { remove_column :accounts, :proxy_configs_conf_file_name }
    safety_assured { remove_column :accounts, :proxy_configs_conf_content_type }
    safety_assured { remove_column :accounts, :proxy_configs_conf_file_size }
    safety_assured { remove_column :accounts, :proxy_configs_conf_updated_at }
  end
end
