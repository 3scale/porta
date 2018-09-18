class AddTenantIdToServiceCubertInfos < ActiveRecord::Migration
  def change
    add_column :service_cubert_infos, :tenant_id, :integer, limit: 8
  end
end
