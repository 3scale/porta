class AddAppAndTokensLimitsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :max_apps, :integer, :default => 10
    add_column :accounts, :max_tokens_per_app, :integer, :default => 10
  end

  def self.down
    remove_column :accounts, :max_apps
    remove_column :accounts, :max_tokens_per_app
  end
end
