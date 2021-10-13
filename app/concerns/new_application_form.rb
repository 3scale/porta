# frozen_string_literal: true

module NewApplicationForm
  extend ActiveSupport::Concern

  included do
    include System::UrlHelpers.system_url_helpers
    delegate :paginated_buyers, to: :accounts_presenter
    delegate :paginated_products, to: :products_presenter
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

  def buyers
    paginated_buyers.map { |b| BuyerPresenter.new(b).new_application_data.as_json }
  end

  def products
    paginated_products.map { |p| ServicePresenter.new(p).new_application_data.as_json }
  end

  def application_defined_fields_data(provider)
    provider.fields_definitions
            .where(target: 'Cinstance')
            .map do |field|
              FieldsDefinitionDecorator.new(field).new_application_data(provider)
            end
  end

  protected

  def accounts_presenter
    # TODO: remove per_page when SelectWithModal updated https://github.com/3scale/porta/pull/2459
    @accounts_presenter ||= Buyers::AccountsIndexPresenter.new(provider: provider, params: { per_page: 500 })
  end

  def products_presenter
    # TODO: remove per_page when SelectWithModal updated https://github.com/3scale/porta/pull/2459
    @products_presenter ||= Api::ServicesIndexPresenter.new(current_user: user, params: { per_page: 500 })
  end
end
