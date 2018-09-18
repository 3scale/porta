# frozen_string_literal: true

class ServiceSubscriptionService
  def initialize(account)
    @account = account
  end

  def unsubscribe(service_contract)
    applications = @account.bought_cinstances.by_service_id(service_contract.service_id)
    active_applications = applications.where.not(state: 'suspended')
    errors = service_contract.errors

    if active_applications.any?
      errors.add :base, :unsuspended_applications, count: active_applications.count
    else
      ServiceContract.transaction do
        applications.destroy_all

        if applications.any?
          errors.add :base, :applications_not_deleted
          raise ActiveRecord::RecordNotDestroyed, I18n.t('service_contracts.unsubscribe_failure')
        end
        service_contract.destroy!
      end
    end
    service_contract
  end
end
