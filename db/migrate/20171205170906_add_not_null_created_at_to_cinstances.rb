class AddNotNullCreatedAtToCinstances < ActiveRecord::Migration
  def change
    Contract.where(created_at: nil).delete_all
    change_column_null(:cinstances, :created_at, false)
  end
end
