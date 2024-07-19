# frozen_string_literal: true

class Buyers::ServiceContractsIndexPresenter

  def initialize(user:, params:, provider:) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    @user = user
    @params = params
    @provider = provider

    @search = ThreeScale::Search.new(params[:search] || params)

    if (service_id = params[:service_id] || search.service_id)
      @service = services.find(service_id)
      search.service_id = service.id
    end

    if (service_plan_id = params[:service_plan_id] || search.service_plan_id)
      plan = provider.service_plans.find(service_plan_id)
      search.plan_id = plan.id
      @service ||= plan.service
    end

    if (buyer_id = params[:account_id]) # rubocop:disable Style/GuardClause
      @buyer = provider.buyers.find(params[:account_id])
      search.account = buyer_id
    end
  end

  attr_reader :user, :search, :params, :service, :provider, :buyer

  delegate :accessible_services, to: :user

  # TODO: when in buyer context, raw services should be user.accessible_service_contracts.where(user_account_id: buyer.id)
  # but instead "buyer_id" is treated as a search param, which is not, and therefore an "empty_view" is never rendered
  def raw_service_contracts
    @raw_service_contracts ||= user.accessible_service_contracts
  end

  def service_contracts
    @service_contracts ||= raw_service_contracts.scope_search(search)
                                                .order_by(*sorting_params)
                                                .includes(plan: %i[pricing_rules], user_account: [:admin_user])
                                                .paginate(pagination_params)
                                                .decorate
  end

  def toolbar_props # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
    plan = search.plan_id ? ServicePlan.find(search.plan_id) : nil

    props = {
      totalEntries: service_contracts.total_entries,
      attributeFilters: [{
        name: 'search[service_id]',
        title: 'Service',
        collection: services_for_filter,
        placeholder: 'Filter by service',
        chip: if (id = search.service_id)
                services.find(id).name
              end,
      }, {
        name: 'search[plan_id]',
        title: 'Plan',
        groupedCollection: plans_for_filter,
        placeholder: 'Filter by plan',
        selected: ({ id: plan.id.to_s, name: plan.name } if plan),
        chip: ("#{plan.name} (#{plan.service.name})" if plan),
      }, {
        name: 'search[state]',
        title: 'State',
        collection: states_for_filter,
        placeholder: 'Filter by state',
        chip: search.state&.capitalize
      }, {
        name: 'search[plan_type]',
        title: 'Plan type',
        collection: plan_types_for_filter,
        placeholder: 'Filter by plan type',
        chip: search.plan_type&.capitalize,
        # TODO: disabled: search.plan_id.present?
      }]
    }

    unless buyer
      props[:attributeFilters].prepend({ name: 'search[account_query]',
                                         title: 'Account',
                                         placeholder: 'Search by account',
                                         chip: search.account_query })
    end

    props
  end

  def empty_state?
    raw_service_contracts.empty?
  end

  def empty_search?
    service_contracts.empty?
  end

  def service?
    @service.present?
  end

  def show_available_subscriptions?
    buyer.present? && services_without_contracts.any?
  end

  def services
    @services ||= accessible_services.includes(:service_plans)
  end

  def services_without_contracts
    @services_without_contracts ||= provider.services_without_contracts(buyer)
  end

  def menu_context
    if params[:account_id]
      %i[audience accounts listing]
    elsif search.service_id.present?
      %i[serviceadmin subscriptions]
    end
  end

  def multiservice?
    @multiservice ||= provider.multiservice?
  end

  private

  def services_for_filter
    services.map do |service|
      { id: service.id.to_s, title: service.name }
    end
  end

  def plans_for_filter
    services.map do |service|
      {
        groupName: service.name,
        groupCollection: service.service_plans.map do |plan|
          { id: plan.id.to_s, title: plan.name }
        end
      }
    end
  end

  def states_for_filter
    ServiceContract.allowed_states.collect(&:to_s).sort.map do |state|
      { id: state, title: state.capitalize }
    end
  end

  def plan_types_for_filter
    %w[free paid].map do |type|
      { id: type, title: type.capitalize }
    end
  end

  def sorting_params
    [params[:sort] || 'cinstances.id', params[:direction] || 'DESC']
  end

  def pagination_params
    { page: params[:page] || 1, per_page: params[:per_page] || 20 }
  end
end
