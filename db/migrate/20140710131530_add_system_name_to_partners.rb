class AddSystemNameToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :system_name, :string
  end
end
