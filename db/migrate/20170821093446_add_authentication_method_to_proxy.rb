class AddAuthenticationMethodToProxy < ActiveRecord::Migration
  def change
    add_column :proxies, :authentication_method, :string
  end
end
