class AddTypeToAuthenticationProviders < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :type, :string

    reversible do |dir|
      dir.up  do
        change_column_default :authentication_providers, :branding_state, nil
        change_column_null :authentication_providers, :branding_state, true

        AuthenticationProvider.where(kind: 'auth0')
            .update_all(branding_state: 'custom_branded', type: 'AuthenticationProvider::Auth0')

        AuthenticationProvider.where(kind: 'base')
            .update_all(branding_state: 'custom_branded', type: 'AuthenticationProvider::Custom')

        AuthenticationProvider.where(kind: 'github').update_all(type: 'AuthenticationProvider::GitHub')

        AuthenticationProvider.where(kind: 'github').where.not(client_id: nil, client_secret: nil)
            .update_all(branding_state: 'custom_branded')
      end
    end
  end
end
