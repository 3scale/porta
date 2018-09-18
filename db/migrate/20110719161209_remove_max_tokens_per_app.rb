class RemoveMaxTokensPerApp < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :max_tokens_per_app
  end

  def self.down
    add_column :accounts, :max_tokens_per_app, :integer, :default => 10
  end
end
