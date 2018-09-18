class AddAlertsServiceId < ActiveRecord::Migration
  def change
    add_column :alerts, :service_id, :int8

    add_index :alerts, [:account_id, :service_id, :state, :cinstance_id], name: 'index_alerts_with_service_id'

    reversible do |dir|
      dir.up  do
        execute <<-SQL.strip_heredoc
          UPDATE `alerts`
          INNER JOIN `cinstances` ON `cinstances`.`id` = `alerts`.`cinstance_id` AND `cinstances`.`type` IN ('Cinstance')
          INNER JOIN `plans` ON `plans`.`id` = `cinstances`.`plan_id` AND `plans`.`type` IN ('ApplicationPlan')
          SET `alerts`.`service_id` = `plans`.`issuer_id`
        SQL
      end
    end
  end
end
