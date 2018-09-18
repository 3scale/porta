class AddSSOAuthorizationIdToUserSession < ActiveRecord::Migration
  def change
    change_table :user_sessions do |table|
      table.references :sso_authorization, index: true, foreign_key: { on_delete: :cascade }, type: :bigint
    end
  end
end
