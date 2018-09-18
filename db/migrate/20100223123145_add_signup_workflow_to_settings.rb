class AddSignupWorkflowToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :signup_workflow, :string, :default => 'with_plans'
  end

  def self.down
    remove_column :settings, :signup_workflow
  end
end
