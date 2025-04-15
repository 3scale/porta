require 'notification_center'

class MessageObserver < ActiveRecord::Observer
  observe :cinstance, :service_contract

  include AfterCommitOn

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

  def plan_changed(contract)
    notify_plan_change_provider(contract)
    notify_plan_change_developer(contract)
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
    return unless contract.user_account&.should_not_be_deleted?
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

  def notify_plan_change_provider(contract)
    plan_changed_publish_event!(contract)
  end

  def notify_plan_change_developer(contract)
    return unless contract.is_a? Cinstance
    contract.messenger.plan_change_for_buyer(contract).deliver
  end
end
