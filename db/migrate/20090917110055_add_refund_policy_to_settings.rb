class AddRefundPolicyToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :refund_policy, :text
  end

  def self.down
    remove_column :settings, :refund_policy
  end
end
