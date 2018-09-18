class CreateAuthenticationProviders < ActiveRecord::Migration
  def change
    create_table :authentication_providers do |t|
      t.string :name
      t.string :system_name
      t.string :client_id
      t.string :client_secret
      t.string :token_url
      t.string :user_info_url
      t.string :authorize_url
      t.string :site
      t.references :account, index: true, limit: 8

      t.timestamps
    end

    add_index :authentication_providers, [:account_id, :system_name], unique: true
  end
end
