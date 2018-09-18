class ProviderPlanChangeObserver < ActiveRecord::Observer
  observe :cinstance

  def plan_changed(contract)
    return unless is_providers?(contract)


    unless (user = find_user(contract))
      Rails.logger.error "Can't observe plan change because contract #{contract.id} does not have user"
      return
    end

    analytics = ThreeScale::Analytics.user_tracking(user)
    analytics.track('Plan Changed'.freeze, properties(contract))
    analytics.group
  end


  protected

  def find_user(contract)
    contract.user_account.admins.first
  end

  def properties(contract)
    plan = contract.plan
    previous_plan = contract.old_plan

    {
        name: contract.name,
        state: contract.state,
        plan_name: plan.name,
        previous_plan_name: previous_plan.try!(:name)
    }
  end

  def is_providers?(contract)
    contract.try!(:user_account).try!(:provider?)
  end
end
