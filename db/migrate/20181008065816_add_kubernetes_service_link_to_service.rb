class AddKubernetesServiceLinkToService < ActiveRecord::Migration
  def change
    add_column :services, :kubernetes_service_link, :string, null: true
  end
end
