class RemoveProxyLogs < ActiveRecord::Migration[5.0]
  def change
    safety_assured {drop_table :proxy_logs}
  end
end
