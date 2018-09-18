class SetDocumentationAnForumPublicAttributesToTrueForConnectAccounts < ActiveRecord::Migration
  def self.up
    Settings.update_all({:documentation_public => true, :forum_public => true})    
  end

  def self.down
    Settings.update_all({:documentation_public => false, :forum_public => false})
  end
end
