class AddHerokuIdToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :heroku_id, :string
  end
end
