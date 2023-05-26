# frozen_string_literal: true

class Buyers::AccountPlansPresenter < PlansBasePresenter
  def initialize(collection:, user:, params: {})
    super(collection: collection, user: user, params: params)
  end

  # This smells of :reek:NilCheck because it is nil check.
  def no_available_plans
    plans.default.nil? && plans.published.empty?
  end

  def plans_index_data
    super.merge({ showNotice: no_available_plans })
  end

  private

  def current_plan
    plans.default&.as_json(root: false, only: %i[id name]) || nil
  end

  def masterize_path
    masterize_admin_buyers_account_plans_path
  end

  def search_href
    admin_buyers_account_plans_path
  end

  def create_button_props
    return unless can_create_plan?(AccountPlan)

    {
      href: new_admin_account_plan_path,
      label: 'Create account plan'
    }
  end
end
