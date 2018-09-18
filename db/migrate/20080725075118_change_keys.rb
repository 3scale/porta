class ChangeKeys < ActiveRecord::Migration
  def self.up
    change_table :cinstances do |t|
      t.rename :sec_userkey, :user_key
      t.rename :sec_providerkey, :provider_public_key
      t.index :user_key, :unique => true
    end
    
    change_table :services do |t|
      t.rename :provider_key, :provider_private_key
    end
  end

  def self.down
    change_table :cinstances do |t|
      t.remove_index :user_key
      t.rename :user_key, :sec_userkey
      t.rename :provider_key, :sec_providerkey 
    end
    
    change_table :services do |t|
      t.rename :provider_private_key, :provider_key
    end
  end
end
