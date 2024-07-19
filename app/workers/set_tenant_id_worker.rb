# frozen_string_literal: true

class SetTenantIdWorker < ApplicationJob
  include Sidekiq::Throttled::Job

  queue_as :low
  sidekiq_throttle concurrency: { limit: 10 }

  TENANT_RELATIONS = %w[backend_apis log_entries"]
  ACCOUNT_RELATIONS = %w[alerts]
  RELATIONS = (TENANT_RELATIONS + ACCOUNT_RELATIONS).freeze

  def perform(object, relations)
    relations.each do |relation|
      assoc = object.public_send(relation)
      assoc.select(:id).where(tenant_id: nil).find_in_batches(batch_size: 100) do |instances|
        ModelTenantIdWorker.perform_later(assoc.klass, instances.map(&:id), object.tenant_id)
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

      enqueue_tenant_relations(relations)
      enqueue_account_relations(relations)
    end

    def enqueue_scope(scope, relations)
      scope.select(:id).find_each do |object|
        SetTenantIdWorker.perform_later(object, relations)
      end
    end

    def enqueue_tenant_relations(relations)
      tenant_relations = relations & TENANT_RELATIONS
      enqueue_scope(Account.tenants, tenant_relations) if tenant_relations.present?
    end

    def enqueue_account_relations(relations)
      account_relations = relations & ACCOUNT_RELATIONS
      enqueue_scope(Account.not_master, account_relations) if account_relations.present?
    end
  end

  class ModelTenantIdWorker < ApplicationJob
    include Sidekiq::Throttled::Job

    queue_as :low
    sidekiq_throttle concurrency: { limit: 10 }

    def perform(model, ids, tenant_id)
      model.where(id: ids).update_all(tenant_id: tenant_id)
    end
  end
end
