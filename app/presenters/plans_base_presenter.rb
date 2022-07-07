# frozen_string_literal: true

class PlansBasePresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(service:, collection:, params: {})
    @service = service
    @collection = collection
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search])
    @sorting_params = "#{params[:sort].presence || 'name'} #{params[:direction].presence || 'asc'}"
  end

  attr_reader :service, :collection, :pagination_params, :search, :sorting_params

<<<<<<< THREESCALE-8066_defaultplan-card-disappears-when-searching
  def plans
    @plans ||= collection.not_custom
                         .reorder('name ASC')
  end

  def table_plans
    @table_plans ||= plans.scope_search(search)
                          .reorder(sorting_params)
  end

  def paginated_table_plans
    @paginated_table_plans ||= table_plans.paginate(pagination_params)
=======
  def paginated_plans
    @paginated_plans ||= plans.paginate(pagination_params)
  end

  def plans
    @plans ||= collection.not_custom
                         .reorder(sorting_params)
                         .scope_search(search)
>>>>>>> master
  end

  def default_plan_select_data
    {
      'plans': plans.to_json(root: false, only: %i[id name]),
      'current-plan': current_plan,
      'path': masterize_path
    }
  end

  def plans_table_data
    {
      columns: columns.to_json,
<<<<<<< THREESCALE-8066_defaultplan-card-disappears-when-searching
      plans: paginated_table_plans.decorate.map(&:index_table_data).to_json,
      count: paginated_table_plans.total_entries,
=======
      plans: paginated_plans.decorate.map(&:index_table_data).to_json,
      count: paginated_plans.total_entries,
>>>>>>> master
      'search-href': search_href
    }
  end

  private

  def current_plan
    raise NoMethodError, "#{__method__} not implemented in #{self.class}"
  end

  def masterize_path
    raise NoMethodError, "#{__method__} not implemented in #{self.class}"
  end

  def search_href
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
