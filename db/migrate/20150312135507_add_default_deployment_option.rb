class AddDefaultDeploymentOption < ActiveRecord::Migration
  def up
    change_column :services, :deployment_option, :string, default: :on_3scale
  end

  def down
    change_column :services, :deployment_option, :string, default: nil
  end
end
