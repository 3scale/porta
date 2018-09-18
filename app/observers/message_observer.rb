require_dependency 'notification_center'

class MessageObserver < ActiveRecord::Observer
  observe :cinstance, :service_contract

  include AfterCommitOn

  def after_commit_on_create(contract)
    return unless should_notify?(contract)
    return if contract.user_account.nil?
    return if contract.user_account.admins.empty?

    contract.messenger.new_contract(contract).deliver
  end

  def after_create(contract)
    event = case contract
            when Cinstance
              Applications::ApplicationCreatedEvent.create(contract, User.current)
            when ServiceContract
              ServiceContracts::ServiceContractCreatedEvent.create(contract, User.current)
    end

    Rails.application.config.event_store.publish_event(event)
  end

  def after_destroy(contract)
    event_classes = case contract
                    when Cinstance
                      [Cinstances::CinstanceCancellationEvent, Applications::ApplicationDeletedEvent]
                    when ServiceContract
                      [ServiceContracts::ServiceContractCancellationEvent]
                    end

    event_classes.each { |event_class| event_class.create_and_publish!(contract) }
  end

  def after_commit_on_update(contract)
    return unless should_notify?(contract)
    # nop
  end

  def after_commit_on_destroy(contract)
    return unless should_notify?(contract)
    return if contract.user_account.nil?

    # Do not send if there is no-one to send the message to.
    return unless contract.provider_account
    return if     contract.provider_account.admins.empty?

    # Do not send message when contract is pending, because that is handled by
    # +after_reject+.
    return if contract.pending?

    contract.messenger.contract_cancellation(contract).deliver
  end

  def plan_changed(contract)
    if contract.provider_account.provider_can_use?(:new_notification_system)
      plan_changed_publish_event!(contract)
    elsif should_notify?(contract)
      contract.messenger.plan_change(contract).deliver
    end
  end

  def expired_trial_period(contract)
    if contract.is_a?(Cinstance)
      event = Cinstances::CinstanceExpiredTrialEvent.create(contract)
      Rails.application.config.event_store.publish_event(event)
    end
  end

  def accepted(contract)
    return unless should_notify?(contract)
    return unless contract.user_account
    return unless contract.plan && contract.plan.approval_required?
    return if     contract.user_account.admins.empty?

    contract.messenger.accept(contract).deliver
  end

  def rejected(contract)
    return unless should_notify?(contract)
    return if contract.user_account.nil?
    return if contract.user_account.admins.empty?
    return if contract.provider_account.blank?

    contract.messenger.reject(contract).deliver
  end

  private

  def plan_changed_publish_event!(contract)
    event_class = case contract
                  when ServiceContract
                    ServiceContracts::ServiceContractPlanChangedEvent
                  when Cinstance
                    Cinstances::CinstancePlanChangedEvent
                  end

    if event_class.present?
      event = event_class.create(contract, User.current)

      Rails.application.config.event_store.publish_event(event)
    end
  end

  def should_notify?(contract)
    NotificationCenter.new(contract).enabled?
  end
end
