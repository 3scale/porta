class AddLimitInServiceIdToServiceCubertInfos < ActiveRecord::Migration
  def change
    change_column :service_cubert_infos, :service_id, :integer, limit: 8
  end
end
