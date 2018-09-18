class AddJanrainToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :janrain_api_key, :string
    add_column :settings, :janrain_relying_party, :string
    Account.providers.find_each do |provider|
      provider.settings.update_attribute( :janrain_api_key, fetch_from_config( provider,:janrain_api_key))
      provider.settings.update_attribute( :janrain_relying_party, fetch_from_config( provider,:janrain_relying_party))
    end
  end

  def self.down
    remove_column :settings, :janrain_relying_party
    remove_column :settings, :janrain_api_key
  end

  private

  def self.fetch_from_config( provider, key)
     provider.config.fetch_deprecated(key)
  end

end
