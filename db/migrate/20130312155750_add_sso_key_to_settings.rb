class AddSsoKeyToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :sso_key, :string, :limit => 256
  end
end
