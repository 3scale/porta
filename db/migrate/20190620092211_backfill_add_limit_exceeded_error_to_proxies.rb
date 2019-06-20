class BackfillAddLimitExceededErrorToProxies < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    Proxy.select(:id).find_in_batches(batch_size: 100) do |batch|
      batch.each { |proxy| proxy.update_column(:error_headers_limits_exceeded, 'text/plain; charset=us-ascii') }
      sleep(0.5)
    end
  end

  def down
    Proxy.select(:id).find_in_batches(batch_size: 100) do |batch|
      batch.each { |proxy| proxy.update_column(:error_headers_limits_exceeded, nil) }
      sleep(0.5)
    end
  end
end
