class AddPlansEndUserRequired < ActiveRecord::Migration
  def self.up
    add_column :plans, :end_user_required, :boolean, :null => false, :default => false
    add_column :cinstances, :end_user_required, :boolean
  end

  def self.down
    remove_column :plans, :end_user_required
    remove_column :cinstances, :end_user_required
  end
end
