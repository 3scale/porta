class AddPaidUntilToCinstances < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :paid_until, :datetime
  end

  def self.down
    remove_column :cinstances, :paid_until
  end
end
