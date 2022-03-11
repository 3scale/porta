# frozen_string_literal: true

class SetTenantIdWorker < ApplicationJob

  def perform(provider)
    provider.update_column(:master, false)

    [:backend_apis, :log_entries, :alerts].each do |relation|
      provider.public_send(relation).where(tenant_id: nil).find_each do |instance|
        ModelTenantIdWorker.perform_later(instance, provider.tenant_id)
      end
    end
  end

  class BatchEnqueueWorker < ApplicationJob
    unique :until_executed

    def perform(*)
      Account.providers.where(master: nil).find_each do |provider|
        SetTenantIdWorker.perform_later(provider)
      end
    end
  end

  class ModelTenantIdWorker < ApplicationJob

    def perform(object, tenant_id)
      object.update_column(:tenant_id, tenant_id)
    end

  end

end
