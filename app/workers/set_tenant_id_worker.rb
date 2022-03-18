# frozen_string_literal: true

class SetTenantIdWorker < ApplicationJob
  queue_as :low

  RELATIONS = ["backend_apis", "log_entries", "alerts"].freeze

  def perform(provider, relations)
    relations.each do |relation|
      assoc = provider.public_send(relation)
      assoc.select(:id).where(tenant_id: nil).find_in_batches(batch_size: 100) do |instances|
        ModelTenantIdWorker.perform_later(assoc.klass, instances.map(&:id), provider.tenant_id)
      end
    end
  end

  class BatchEnqueueWorker < ApplicationJob
    unique :until_executed
    queue_as :low

    def self.validate_params(*relations)
      raise "you must pass relations to fix" if relations.empty?
      raise "Only relations #{RELATIONS} are supported" unless (relations - RELATIONS).empty?
    end
    delegate :validate_params, :to => :class

    def perform(*relations)
      validate_params(*relations)

      Account.tenants.select(:id).find_each do |provider|
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
