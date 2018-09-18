class AddEnableInCountries < ActiveRecord::Migration
  def change
    add_column :countries, :enabled, :boolean, default: true
  end
end
