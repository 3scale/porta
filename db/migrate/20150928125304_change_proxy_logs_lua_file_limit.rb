class ChangeProxyLogsLuaFileLimit < ActiveRecord::Migration
  def change
    change_column :proxy_logs, :lua_file, :text, :limit => 16777215
  end
end
