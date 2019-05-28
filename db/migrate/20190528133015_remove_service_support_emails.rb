class RemoveServiceSupportEmails < ActiveRecord::Migration
  def change
    safety_assured { remove_column :services, :tech_support_email, :string }
    safety_assured { remove_column :services, :admin_support_email, :string }
  end
end
