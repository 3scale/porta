class AddHerokuNameToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :heroku_name, :string
  end
end
