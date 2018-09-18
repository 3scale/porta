class LandingPageIsAppsToSettings < ActiveRecord::Migration

  def self.up
    # Simba, there is no such thing as temporary hack
    add_column :settings, :buyer_landing_url_is_apps_page, :boolean

    Account.providers.find_each do |provider|
      provider.settings.update_attribute( :buyer_landing_url_is_apps_page,
                                          provider.config.fetch_deprecated(:buyer_landing_url_is_apps_page))

    end
  end

  def self.down
    remove_column :settings, :buyer_landing_url_is_apps_page
  end
end
