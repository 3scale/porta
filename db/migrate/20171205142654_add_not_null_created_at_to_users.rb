class AddNotNullCreatedAtToUsers < ActiveRecord::Migration
  def change
    User.where(created_at: nil).delete_all
    change_column_null(:users, :created_at, false)
  end
end
