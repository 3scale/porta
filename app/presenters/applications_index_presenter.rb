# frozen_string_literal: true

class ApplicationsIndexPresenter
  include System::UrlHelpers.system_url_helpers
  include ApplicationsHelper

  delegate :can?, to: :ability

  def initialize(application_plans:, accessible_services:, cinstances:, search:, service:, current_account:, accessible_plans:, account:, user:)
    @accessible_services = accessible_services
    @application_plans = application_plans
    @cinstances = cinstances
    @search = search
    @service = service
    @current_account = current_account
    @accessible_plans = accessible_plans
    @account = account
    @ability = Ability.new(user)
  end

  attr_reader :application_plans, :accessible_services, :cinstances, :search, :service, :current_account, :accessible_plans, :account, :ability

  def toolbar_props
    show_application_plans = !application_plans.empty? && !current_account.master_on_premises?
    service_column_visible = service.nil? && current_account.multiservice?
    new_application_path = if service.present?
                             new_admin_service_application_path(service)
                           elsif account.present?
                             create_application_link_href(account)
                           else
                             new_provider_admin_application_path
                           end

    props = {
      totalEntries: cinstances.total_entries,
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

    if account.nil? # Probably use other variable like current_account
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

    if current_account.settings.finance.allowed?
      props[:attributeFilters].append({ name: 'search[plan_type]',
                                        title: 'Plan type',
                                        collection: [{ id: :free, title: 'Free' },
                                                     { id: :paid, title: 'Paid' }],
                                        placeholder: 'Plan type',
                                        chip: search.plan_type&.capitalize })
    end

    props
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
