class DeleteProfilesWithoutAccount < ActiveRecord::Migration
  def self.up
    Profile.all(
      :conditions => ['accounts.id IS NULL'],
      :include => :account).each do |profile|
      
      profile.destroy
    end
  end

  def self.down
  end
end
