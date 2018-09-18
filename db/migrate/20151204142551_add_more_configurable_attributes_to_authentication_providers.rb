class AddMoreConfigurableAttributesToAuthenticationProviders < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :username_key, :string, default: 'login'
    add_column :authentication_providers, :trust_email, :boolean, default: false
  end
end
