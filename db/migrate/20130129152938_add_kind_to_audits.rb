class AddKindToAudits < ActiveRecord::Migration
  def self.up
    add_column :audits, :kind, :string
    add_index :audits, :kind
    execute "update audits set kind=auditable_type"
  end

  def self.down
    remove_column :audits, :kind
  end
end
