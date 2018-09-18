class DefaultValueForAccessTokensOwnerType < ActiveRecord::Migration
  def up
    change_column :access_tokens, :owner_type, :string, default: 'User'
  end

  def down
    change_column :access_tokens, :owner_type, :string, default: nil
  end
end
