# frozen_string_literal: true

class ApplicationsIndexPresenter
  include System::UrlHelpers.system_url_helpers
  include ApplicationsHelper

  delegate :can?, to: :ability
  delegate :total_entries, to: :applications

  def initialize(application_plans:, accessible_services:, service:, provider:, accessible_plans:, buyer:, user:, params:)
    @accessible_services = accessible_services
    @application_plans = application_plans
    @service = service
    @provider = provider
    @accessible_plans = accessible_plans
    @buyer = buyer
    @user = user
    @ability = Ability.new(user)
    @sorting_params = [params[:sort], params[:direction]]
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }

    @search = ThreeScale::Search.new(params[:search] || params)
    @search.account = params['account_id'] if params.key?('account_id')
    @search.plan_id = params['application_plan_id'] if params.key?('application_plan_id')
  end

  attr_reader :ability, :accessible_plans, :accessible_services, :application_plans, :buyer,
              :pagination_params, :provider, :search, :service, :sorting_params, :user

  def toolbar_props # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    show_application_plans = !application_plans.empty? && !provider.master_on_premises?
    service_column_visible = service.nil? && provider.multiservice?
    new_application_path = if service.present?
                             new_admin_service_application_path(service)
                           elsif buyer.present?
                             create_application_link_href
                           else
                             new_provider_admin_application_path
                           end

    props = {
      totalEntries: total_entries,
      actions: [{
        label: 'Create an application',
        href: new_application_path,
        variant: :primary
      }],
      attributeFilters: [{
        name: 'search[name]',
        title: 'Name',
        placeholder: 'Search by name',
        chip: search.name
      }, {
        name: 'search[state]',
        title: 'State',
        collection: states_for_filter,
        placeholder: 'State',
        chip: search.state&.capitalize
      }]
    }

    if buyer.nil?
      props[:attributeFilters].append({ title: 'Account',
                                        name: 'search[account_query]',
                                        placeholder: 'Search by account',
                                        chip: search.account_query })
    end

    if service_column_visible
      services_for_filter = accessible_services_for_filter
      props[:attributeFilters].append({ name: 'search[service_id]',
                                        title: 'Product',
                                        collection: services_for_filter,
                                        placeholder: 'Product',
                                        chip: if (service_id = search.service_id)
                                                accessible_services.find(service_id).name
                                              end })
    end

    if show_application_plans
      if service_column_visible
        collection = accessible_services.reject { |service| service.application_plans.empty? }
                                        .map do |service|
                                          {
                                            groupName: service.name,
                                            groupCollection: service.application_plans.map { |plan| plan_to_select_item(plan) }
                                          }
                                        end
        props[:attributeFilters].append({ name: 'search[plan_id]',
                                          title: 'Plan',
                                          groupedCollection: collection,
                                          placeholder: 'Plan',
                                          chip: if (plan_id = search.plan_id)
                                                  accessible_plans.find(plan_id).name
                                                end })
      else
        props[:attributeFilters].append({ name: 'search[plan_id]',
                                          title: 'Plan',
                                          collection: application_plans.map { |plan| plan_to_select_item(plan) },
                                          placeholder: 'Plan',
                                          chip: if (plan_id = search.plan_id)
                                                  accessible_plans.find(plan_id).name
                                                end })
      end
    end

    if provider.settings.finance.allowed?
      props[:attributeFilters].append({ name: 'search[plan_type]',
                                        title: 'Plan type',
                                        collection: [{ id: :free, title: 'Free' },
                                                     { id: :paid, title: 'Paid' }],
                                        placeholder: 'Plan type',
                                        chip: search.plan_type&.capitalize })
    end

    props
  end

  def raw_applications
    return @raw_applications if @raw_applications.present?

    raw = user.accessible_cinstances.not_bought_by(provider)
    @raw_applications = if service.present?
                          raw.where(service: service)
                        elsif buyer.present?
                          raw.bought_by(buyer)
                        else
                          raw
                        end
  end

  def applications
    @applications ||= raw_applications.scope_search(search)
                                      .order_by(*sorting_params)
                                      .preload(:service, user_account: %i[admin_user], plan: %i[pricing_rules])
                                      .paginate(pagination_params)
                                      .decorate
  end

  def empty_state?
    raw_applications.empty?
  end

  # TODO: need to refactor this method, there is no default return value
  def create_application_link_href
    if buyer.bought_cinstances.size.zero?
      new_admin_buyers_account_application_path(buyer)
    elsif can?(:admin, :multiple_applications)
      if can?(:see, :multiple_applications)
        new_admin_buyers_account_application_path(buyer)
      else
        admin_upgrade_notice_path(:multiple_applications)
      end
    end
  end

  private

  def states_for_filter
    Cinstance.allowed_states.collect(&:to_s).sort.map do |state|
      { id: state, title: state.capitalize }
    end
  end

  def accessible_services_for_filter
    accessible_services.map do |service|
      { id: service.id.to_s, title: service.name }
    end
  end

  def plan_to_select_item(plan)
    { id: plan.id.to_s, title: plan.name }
  end
end
