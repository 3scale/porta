class AddKindToAuthenticationProviders < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :kind, :string
  end
end
