class RenameTypeOfBuiltinPages < ActiveRecord::Migration
  def self.up
    execute %{ UPDATE cms_templates SET type = 'CMS::Builtin::Page' WHERE type = 'CMS::BuiltinPage' }
  end

  def self.down
    execute %{ UPDATE cms_templates SET type = 'CMS::BuiltinPage' WHERE type = 'CMS::Builtin::Page' }
  end
end
