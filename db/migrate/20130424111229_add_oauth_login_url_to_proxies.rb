class AddOauthLoginUrlToProxies < ActiveRecord::Migration
  def change
    add_column :proxies, :oauth_login_url, :string
  end
end
