class CreateSettingsObjectForAccounts < ActiveRecord::Migration
  def self.up
    Account.with_deleted.all.each do |a|
      Settings.create(:account_id => a.id) unless !a.settings.nil?
    end
  end

  def self.down
    Settings.delete_all
  end
end
