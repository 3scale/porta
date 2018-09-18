class AddAuthenticationStrategyToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :authentication_strategy, :string, :null => false, :default => 'internal'
  end

  def self.down
    remove_column :settings, :authentication_strategy
  end
end
