class AddLogoutUrlToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :logout_url, :string
  end
end
