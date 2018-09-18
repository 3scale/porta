class RemoveTimezoneFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :timezone
  end

  def down
    add_column :users, :timezone, :string
  end
end
