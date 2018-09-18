class ChangeServiceDeploymentOptions < ActiveRecord::Migration
  def up
    change_column_default(:services, :deployment_option, 'hosted')

    Service.transaction do
      execute <<~SQL.strip
        UPDATE `services` SET `services`.`deployment_option` = 'hosted' WHERE `services`.`deployment_option` = 'on_3scale';
      SQL
      execute <<~SQL.strip
        UPDATE `services` SET `services`.`deployment_option` = 'self_managed' WHERE `services`.`deployment_option` = 'on_premise';
      SQL
    end
  end

  def down
    change_column_default(:services, :deployment_option, 'on_3scale')

    Service.transaction do
      execute <<~SQL.strip
        UPDATE `services` SET `services`.`deployment_option` = 'on_3scale' WHERE `services`.`deployment_option` = 'hosted';
      SQL
      execute <<~SQL.strip
        UPDATE `services` SET `services`.`deployment_option` = 'on_premise' WHERE `services`.`deployment_option` = 'self_managed';
      SQL
    end
  end
end
