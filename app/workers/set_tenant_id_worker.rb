# frozen_string_literal: true

class SetTenantIdWorker < ApplicationJob

  def perform(provider_batch)
    provider_batch.each do |provider|
      # Set the master field to false
      provider.master = false
      provider.save!

      # Update the backend_apis, log_entries and alerts to propagate the tenant_id from the updated
      # provider
      {
        BackendApi => :account_id,
        LogEntry => :provider_id,
        Alert => :account_id,
      }.each do |model, relation|
        q = {}
        q[relation] = provider.id
        
        model.where(q).each do |instance|
          instance.update!(tenant_id: provider.tenant_id)
        end
      end
    end
  end

  class BatchEnqueueWorker < ApplicationJob
    unique :until_executed

    def perform(*)
      Account.providers.not_master.find_in_batches(batch_size: 100).each do |provider_batch|
        SetTenantIdWorker.perform_later(provider_batch)
      end
    end
  end

end
