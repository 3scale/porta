class AuditedChangesMediumText < ActiveRecord::Migration[5.2]
  def up
    return unless System::Database.mysql?

    safety_assured do
      change_column :audits, :audited_changes, :text, limit: 16.megabytes - 1
    end
  end
end
