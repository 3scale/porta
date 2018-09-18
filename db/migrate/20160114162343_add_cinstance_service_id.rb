class AddCinstanceServiceId < ActiveRecord::Migration
  def change
    add_column :cinstances, :service_id, :int8

    add_index :cinstances, [:type, :service_id, :created_at]
    add_index :cinstances, [:type, :service_id, :plan_id, :state]
    add_index :cinstances, [:type, :service_id, :state, :first_traffic_at], name: 'idx_cinstances_service_state_traffic'

    reversible do |dir|
      dir.up  do
        execute <<-SQL.strip_heredoc
          UPDATE `cinstances`
          INNER JOIN `plans` ON `cinstances`.`plan_id` = `plans`.`id` AND `plans`.`type` IN ('ApplicationPlan')
          SET `cinstances`.`service_id` = `plans`.`issuer_id`
          WHERE `cinstances`.`type` IN ('Cinstance')
        SQL
      end
    end
  end
end
