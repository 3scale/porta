# frozen_string_literal: true

class SetTenantIdWorker < ApplicationJob
  queue_as :low

  RELATIONS = ["backend_apis", "log_entries", "alerts"].freeze

  def perform(provider, relations)
    provider.update_column(:master, false)

    relations.each do |relation|
      model = provider.public_send(relation)
      model.select(:id).where(tenant_id: nil).find_in_batches(batch_size: 100) do |instances|
        ModelTenantIdWorker.perform_later(model, instances.map(&:id), provider.tenant_id)
      end
    end
  end

  class BatchEnqueueWorker < ApplicationJob
    unique :until_executed
    queue_as :low

    def perform(*relations)
      raise "you must pass relations to fix" if relations.empty?
      raise "Only relations #{RELATIONS} are supported" unless (relations - RELATIONS).empty?

      Account.providers.select(:id).where(master: nil).find_each do |provider|
        SetTenantIdWorker.perform_later(provider, relations)
      end
    end
  end

  class ModelTenantIdWorker < ApplicationJob
    queue_as :low

    def perform(model, ids, tenant_id)
      model.where(id: ids).update_all(tenant_id: tenant_id)
    end
  end
end
