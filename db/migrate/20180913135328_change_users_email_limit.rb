class ChangeUsersEmailLimit < ActiveRecord::Migration
  def change
    change_column :users, :email, :string, limit: 255
  end
end
