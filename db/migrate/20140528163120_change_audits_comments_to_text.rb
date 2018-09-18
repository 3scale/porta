class ChangeAuditsCommentsToText < ActiveRecord::Migration
  def up
    change_column :audits, :comment, :text
  end

  def down
    change_column :audits, :comment, :string, limit: 65535
  end
end
