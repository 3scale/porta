# frozen_string_literal: true

require 'progress_counter'

class BackfillAddActsAsProductToService < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    return puts "Nothing to do, this migration should not be executed"
    progress = ProgressCounter.new(Service.count)
    Service.all.select(:id).find_in_batches(batch_size: 200) do |records|
      Service.where(id: records.map(&:id)).update_all act_as_product: false
      progress.call(increment: records.size)
    end
  end
end
