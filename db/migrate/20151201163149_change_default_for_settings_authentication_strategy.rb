class ChangeDefaultForSettingsAuthenticationStrategy < ActiveRecord::Migration
  def change
    change_column :settings, :authentication_strategy, :string, default: 'oauth2', null: false
  end
end
