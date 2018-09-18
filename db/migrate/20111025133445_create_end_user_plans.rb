class CreateEndUserPlans < ActiveRecord::Migration
  def self.up
    create_table :end_user_plans do |t|
      t.belongs_to :service, :null => false
      t.string :name, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :end_user_plans
  end
end
