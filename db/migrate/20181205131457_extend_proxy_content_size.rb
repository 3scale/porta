class ExtendProxyContentSize < ActiveRecord::Migration
  def change
    # Oracle does not need this as it is already a CLOB
    change_column :proxy_configs, :content, :mediumtext unless System::Database.oracle?
  end
end
