class RenameContractIdToPlanIdInVariousTables < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE cinstances DROP FOREIGN KEY fk_ct_contract_id"
    execute "ALTER TABLE cinstances DROP INDEX fk_ct_contract_id"
    rename_column :cinstances, :contract_id, :plan_id
    rename_column :pricing_rules, :contract_id, :plan_id
    rename_column :usage_limits, :contract_id, :plan_id
    execute "ALTER TABLE cinstances ADD CONSTRAINT fk_ct_contract_id foreign key (plan_id) references plans (id);"
  end

  def self.down
    rename_column :usage_limits, :plan_id, :contract_id
    rename_column :pricing_rules, :plan_id, :contract_id
    rename_column :cinstances, :plan_id, :contract_id
  end
end
