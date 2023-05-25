# frozen_string_literal: true

class PlansBasePresenter
  include System::UrlHelpers.system_url_helpers
  include PlansHelper

  delegate :can?, to: :ability

  # This smells of :reek:FeatureEnvy but we don't care
  def initialize(collection:, user:, params:)
    @collection = collection
    @ability = Ability.new(user)
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search])
    @sorting_params = { "plans.#{params[:sort].presence || 'name'}": "#{params[:direction].presence || 'asc'}" }
                        .merge({ 'plans.name': 'asc' }) { |_, original, _| original }
  end

  attr_reader :ability, :collection, :pagination_params, :search, :sorting_params

  def paginated_table_plans
    @paginated_table_plans ||= plans.scope_search(search)
                                    .reorder(sorting_params)
                                    .paginate(pagination_params)
  end

  # Must match DefaultPlanSelectCard#Props
  def default_plan_select_data
    {
      plans: plans.reorder(name: :asc).as_json(root: false, only: %i[id name]),
      initialDefaultPlan: current_plan,
      path: masterize_path
    }
  end

  # Must match DefaultPlanSelectCard#Props
  def plans_table_data
    {
      createButton: create_button_props,
      columns: columns,
      plans: paginated_table_plans.decorate.map(&:index_table_data),
      count: paginated_table_plans.total_entries,
    }
  end

  def plans_index_data
    {
      showNotice: respond_to?(:no_available_plans) && no_available_plans,
      defaultPlanSelectProps: default_plan_select_data.as_json,
      plansTableProps: plans_table_data.as_json
    }
  end

  private

  def plans
    @plans ||= collection.not_custom
  end

  def current_plan
    raise NoMethodError, "#{__method__} not implemented in #{self.class}"
  end

  def masterize_path
    raise NoMethodError, "#{__method__} not implemented in #{self.class}"
  end

  def search_href
    raise NoMethodError, "#{__method__} not implemented in #{self.class}"
  end

  def create_button_props
    raise NoMethodError, "#{__method__} not implemented in #{self.class}"
  end

  def columns
    [
      { attribute: :name, title: Plan.human_attribute_name(:name) },
      { attribute: :contracts_count, title: Plan.human_attribute_name(:contracts) },
      { attribute: :state, title: Plan.human_attribute_name(:state) }
    ]
  end
end
