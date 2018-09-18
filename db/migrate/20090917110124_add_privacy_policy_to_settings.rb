class AddPrivacyPolicyToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :privacy_policy, :text
  end

  def self.down
    remove_column :settings, :privacy_policy
  end
end
