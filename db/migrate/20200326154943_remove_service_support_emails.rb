# frozen_string_literal: true

class RemoveServiceSupportEmails < ActiveRecord::Migration[5.0]
  def change
    safety_assured { remove_column :services, :tech_support_email, :string }
    safety_assured { remove_column :services, :admin_support_email, :string }
  end
end
