class BuyerCanSeeLogRequests < ActiveRecord::Migration
  def self.up
    add_column :services, :buyer_can_see_log_requests, :boolean, :default => false
  end

  def self.down
    remove_column :services, :buyer_can_see_log_requests
  end
end
