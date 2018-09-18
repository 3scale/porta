class AddAuthenticationIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_id, :string
  end
end
