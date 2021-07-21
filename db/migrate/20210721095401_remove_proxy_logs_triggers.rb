class RemoveProxyLogsTriggers < ActiveRecord::Migration[5.0]
  def change
    System::Database.triggers.find { |trigger| trigger.table == 'proxy_logs' }&.drop
  end
end
