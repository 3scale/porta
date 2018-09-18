class AddAuthenticationProvidersAccountType < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :account_type, :string, default: 'Developer', null: false
  end
end
