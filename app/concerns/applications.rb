# frozen_string_literal: true

module Applications
  extend ActiveSupport::Concern

  included do
    include System::UrlHelpers.system_url_helpers
  end

  def new_application_form_base_data(provider, cinstance = nil)
    # TODO: Reduce data by not including service_plans when service_plans_management_visible? is false
    data = {
      'create-application-plan-path': new_admin_service_application_plan_path(':id'),
      'create-service-plan-path': new_admin_service_service_plan_path(':id'),
      'service-subscriptions-path': admin_buyers_account_service_contracts_path(':id'),
      'service-plans-allowed': service_plans_management_visible?.to_json,
      'defined-fields': application_defined_fields_data(provider).to_json
    }
    data[:errors] = cinstance.errors.to_json if cinstance
    data
  end

  def raw_buyers
    # This has to be the samne collection as in Buyers::AccountsController#index
    provider.buyer_accounts
            .not_master
            .order(created_at: :desc, id: :asc)
  end

  def filtered_buyers(search)
    raw_buyers.scope_search(search)
  end

  def paginated_buyers
    raw_buyers.paginate(pagination_params)
  end

  def raw_products
    # This has to be the samne collection as in Api::ServicesController#index
    provider.accessible_services
            .order(updated_at: :desc)
  end

  def filtered_products(search)
    raw_products.scope_search(search)
  end

  def paginated_products
    raw_products.paginate(pagination_params)
  end

  def most_recently_created_buyers
    BuyerDecorator.decorate_collection(raw_buyers.limit(20))
                  .map(&:new_application_data)
  end

  def most_recently_updated_products
    ServiceDecorator.decorate_collection(raw_products.limit(20))
                    .map(&:new_application_data)
  end

  def application_defined_fields_data(provider)
    provider.fields_definitions
            .where(target: 'Cinstance')
            .map do |field|
              FieldsDefinitionDecorator.new(field).new_application_data(provider)
            end
  end
end
