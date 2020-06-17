class AddNewColumnToAccountsBoughtCInstancesCount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :bought_cinstances_count, :integer
  end
end
