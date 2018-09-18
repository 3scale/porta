class RemoveBuyerLandingUrlIsAppsPage < ActiveRecord::Migration
  def up
    remove_column :settings, :buyer_landing_url_is_apps_page
  end

  def down
    add_column :settings, :buyer_landing_url_is_apps_page, :boolean
  end
end
