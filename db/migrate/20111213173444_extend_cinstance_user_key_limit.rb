class ExtendCinstanceUserKeyLimit < ActiveRecord::Migration
  def self.up
    change_column(:cinstances, :user_key, :string, :limit => 256)
  end

  def self.down
    change_column(:cinstances, :user_key, :string, :limit => 255)
  end
end
