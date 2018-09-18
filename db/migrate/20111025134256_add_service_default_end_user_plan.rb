class AddServiceDefaultEndUserPlan < ActiveRecord::Migration
  def self.up
    change_table :services do |t|
      t.belongs_to :default_end_user_plan
    end
  end

  def self.down
    remove_column :services, :default_end_user_plan_id
  end
end
