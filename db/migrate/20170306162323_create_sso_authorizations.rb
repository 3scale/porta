class CreateSSOAuthorizations < ActiveRecord::Migration
  def change
    create_table :sso_authorizations do |t|
      t.string :uid
      t.references :authentication_provider, index: true, foreign_key: true, type: :bigint
      t.references :user, index: true, foreign_key: true, type: :bigint
      t.timestamps
    end
  end
end
