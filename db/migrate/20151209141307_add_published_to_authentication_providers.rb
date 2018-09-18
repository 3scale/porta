class AddPublishedToAuthenticationProviders < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :published, :boolean, default: false
  end
end
