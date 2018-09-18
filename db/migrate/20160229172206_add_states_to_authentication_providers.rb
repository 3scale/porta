class AddStatesToAuthenticationProviders < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :branding_state, :string, default: "threescale_branded", null: false
  end
end
