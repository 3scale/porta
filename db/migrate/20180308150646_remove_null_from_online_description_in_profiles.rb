class RemoveNullFromOnlineDescriptionInProfiles < ActiveRecord::Migration
  def change
    change_column_null :profiles, :oneline_description, true
  end
end
