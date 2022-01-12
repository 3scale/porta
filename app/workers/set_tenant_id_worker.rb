# frozen_string_literal: true

class SetTenantIdWorker < ApplicationJob

  def perform(provider)
    provider.update_column(:master, false)

    {
      BackendApi => :account_id,
      LogEntry => :provider_id,
      Alert => :account_id,
    }.each do |model, relation|
      model.where(relation => provider.id).find_each do |instance|
        ModelTenantIdWorker.perform_later(instance, :tenant_id, provider)
      end
    end
  end

  class BatchEnqueueWorker < ApplicationJob
    unique :until_executed

    def perform(*)
      Account.providers.not_master.find_each do |provider_batch|
        SetTenantIdWorker.perform_later(provider_batch)
      end
    end
  end

  class ModelTenantIdWorker < ApplicationJob

    def perform(object, attribute, provider)
      object.update_column(attribute, provider.tenant_id)
    end

  end

end
