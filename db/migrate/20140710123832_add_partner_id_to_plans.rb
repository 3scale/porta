class AddPartnerIdToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :partner_id, :integer
  end
end
