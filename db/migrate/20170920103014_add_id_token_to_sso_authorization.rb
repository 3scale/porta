class AddIdTokenToSSOAuthorization < ActiveRecord::Migration
  def change
    add_column :sso_authorizations, :id_token, :text
  end
end
