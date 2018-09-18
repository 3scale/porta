class IncreaseAuditedCommentSize < ActiveRecord::Migration
  def up
    change_column :audits, :comment, :string, limit: 65535
  end

  def down
    change_column :audits, :comment, :string, limit: 255
  end
end
