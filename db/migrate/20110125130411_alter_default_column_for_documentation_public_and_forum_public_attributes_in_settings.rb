class AlterDefaultColumnForDocumentationPublicAndForumPublicAttributesInSettings < ActiveRecord::Migration
  def self.up
    change_column_default(:settings, :documentation_public, true)
    change_column_default(:settings, :forum_public, true)
  end

  def self.down
    change_column_default(:settings, :documentation_public, false)
    change_column_default(:settings, :forum_public, false)
  end
end


