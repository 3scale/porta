class BackfillStateForBackendApis < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    progress = ProgressCounter.new(BackendApi.count)
    BackendApi.all.select(:id).find_in_batches(batch_size: 200) do |records|
      BackendApi.where(id: records.map(&:id)).update_all(state: :published)
      progress.call(increment: records.size)
    end
  end
end
