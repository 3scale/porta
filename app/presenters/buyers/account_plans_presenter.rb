# frozen_string_literal: true

class Buyers::AccountPlansPresenter < PlansBasePresenter
  def initialize(collection:, params: {})
    super(collection: collection, params: params)
  end

  # This smells of :reek:NilCheck because it is nil check.
  def no_available_plans
    plans.default.nil? && plans.published.empty?
  end

  private

  def current_plan
    plans.default&.to_json(root: false, only: %i[id name]) || nil.to_json
  end

  def masterize_path
    masterize_admin_buyers_account_plans_path
  end

  def search_href
    admin_buyers_account_plans_path
  end
end
