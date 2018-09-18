class ChangeContractIdToPlanIdInChangesFieldInAudits < ActiveRecord::Migration
  def self.up
    execute('UPDATE audits SET changes = REPLACE(changes, "\ncontract_id:", "\nplan_id:")
             WHERE auditable_type = "Cinstance"')
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end
