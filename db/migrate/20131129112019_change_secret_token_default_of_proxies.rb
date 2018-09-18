class ChangeSecretTokenDefaultOfProxies < ActiveRecord::Migration
  def up
    change_column :proxies , :secret_token, :string, :null => false
    change_column_default :proxies, :secret_token, nil
  end

  def down
  end
end
