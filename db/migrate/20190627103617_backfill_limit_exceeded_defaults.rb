class BackfillLimitExceededDefaults < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    Proxy.select(:id).find_in_batches(batch_size: 100) do |batch|
      batch.each { |proxy| proxy.update_columns(error_status_limits_exceeded: 429, error_limits_exceeded: "Usage limit exceeded") }
      sleep(0.5)
    end
  end

  def down
    Proxy.select(:id).find_in_batches(batch_size: 100) do |batch|
      batch.each { |proxy| proxy.update_columns(error_status_limits_exceeded: nil, error_limits_exceeded: nil) }
      sleep(0.5)
    end
  end
end
