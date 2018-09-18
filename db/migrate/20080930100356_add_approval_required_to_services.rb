class AddApprovalRequiredToServices < ActiveRecord::Migration
  def self.up
    change_table :services do |t|
      t.boolean :approval_required, :null => false, :default => false
    end
  end

  def self.down
    change_table :services do |t|
      t.remove :approval_required
    end
  end
end
