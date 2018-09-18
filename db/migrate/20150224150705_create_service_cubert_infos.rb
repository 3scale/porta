class CreateServiceCubertInfos < ActiveRecord::Migration
  def change
    create_table :service_cubert_infos do |t|
      t.string :bucket_id
      t.references :service
      t.timestamps
    end
  end
end
