class RemoveObsoleteConfigurationColumns < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :multiple_cinstances_allowed
    remove_column :accounts, :backend_v2
    remove_column :settings, :signup_workflow
    remove_column :settings, :authentication_strategy
  end

  def self.down
    add_column :settings, :authentication_strategy,     :string,  :default => 'internal'
    add_column :settings, :signup_workflow,             :string,  :default => 'with_plans'
    add_column :accounts, :backend_v2,                  :boolean, :default => true
    add_column :accounts, :multiple_cinstances_allowed, :boolean, :default => false
  end
end
