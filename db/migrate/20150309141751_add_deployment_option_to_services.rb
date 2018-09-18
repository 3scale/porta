class AddDeploymentOptionToServices < ActiveRecord::Migration
  def change
    add_column :services, :deployment_option, :string
  end
end