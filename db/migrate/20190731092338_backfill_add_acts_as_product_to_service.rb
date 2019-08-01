# frozen_string_literal: true

class BackfillAddActsAsProductToService < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    Service.find_in_batches(batch_size: 200) do |records|
      Service.where(id: records.map(&:id)).update_all act_as_product: false
      sleep(0.5)
    end
  end
end
