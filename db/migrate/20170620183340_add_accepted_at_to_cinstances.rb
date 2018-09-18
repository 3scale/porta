class AddAcceptedAtToCinstances < ActiveRecord::Migration
  def change
    add_column :cinstances, :accepted_at, :datetime
  end
end
