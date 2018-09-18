class RemoveBuyerCanSeeLogRequests < ActiveRecord::Migration
  def change
    remove_column :services, :buyer_can_see_log_requests
  end
end
