class AddServiceContractServiceId < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up  do
        execute <<-SQL.strip_heredoc
          UPDATE `cinstances`
          INNER JOIN `plans` ON `cinstances`.`plan_id` = `plans`.`id` AND `plans`.`type` IN ('ServicePlan')
          SET `cinstances`.`service_id` = `plans`.`issuer_id`
          WHERE `cinstances`.`type` IN ('ServiceContract') and `cinstances`.`service_id` IS NULL
        SQL
      end
    end
  end
end
