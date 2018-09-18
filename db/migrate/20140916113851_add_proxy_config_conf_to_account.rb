class AddProxyConfigConfToAccount < ActiveRecord::Migration
  def change
      add_attachment :accounts, :proxy_configs_conf
  end
end
