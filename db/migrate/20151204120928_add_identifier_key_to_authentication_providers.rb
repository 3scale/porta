class AddIdentifierKeyToAuthenticationProviders < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :identifier_key, :string, default: 'id'
  end
end
