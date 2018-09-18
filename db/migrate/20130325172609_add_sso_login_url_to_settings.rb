class AddSsoLoginUrlToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :sso_login_url, :string
  end
end
