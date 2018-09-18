class AddVariableCostPaidUntilToCinstances < ActiveRecord::Migration

  # there was a separate migration on connect adding this column, without this condition migrating from connect will fail
  def self.up
    unless Cinstance.column_names.include?("variable_cost_paid_until")
      add_column :cinstances, :variable_cost_paid_until, :datetime
    end
  end

  def self.down
    if Cinstance.column_names.include?("variable_cost_paid_until")
      remove_column :cinstances, :variable_cost_paid_until
    end
  end
end
