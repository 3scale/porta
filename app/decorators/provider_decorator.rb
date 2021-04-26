# frozen_string_literal: true

class ProviderDecorator < ApplicationDecorator
  include System::UrlHelpers.system_url_helpers

  self.include_root_in_json = false

  def new_application_form_data(buyer: nil, service: nil, cinstance: nil)
    data = {
      'create-application-path': admin_buyers_applications_path,
      'create-application-plan-path': new_admin_service_application_plan_path(':id'),
      'create-service-plan-path': new_admin_service_service_plan_path(':id'),
      'service-subscriptions-path': admin_buyers_account_service_contracts_path(':id'),
      'service-plans-allowed': settings.service_plans.allowed?.to_json,
      'defined-fields': application_defined_fields_data.to_json
    }

    data.merge!(account_context_new_application_form_data(buyer)) if buyer
    data[:buyers] = application_buyers_data.to_json unless buyer
    data[:product] = ServiceDecorator.new(service).new_application_data.to_json if service
    data[:products] = application_products_data.to_json unless service
    data[:errors] = cinstance.errors.to_json if cinstance

    data
  end

  def account_context_new_application_form_data(buyer)
    {
      'create-application-path': admin_buyers_account_applications_path(buyer),
      buyer: BuyerDecorator.new(buyer).new_application_data.to_json
    }
  end

  def application_products_data
    accessible_services.order(updated_at: :desc)
                       .map do |service|
                         ServiceDecorator.new(service).new_application_data
                       end
  end

  def application_buyers_data
    buyer_accounts.not_master
                  .order(created_at: :desc)
                  .map do |buyer|
                    BuyerDecorator.new(buyer).new_application_data
                  end
  end

  def application_defined_fields_data
    fields_definitions.where(target: 'Cinstance')
                      .map do |field|
                        FieldsDefinitionDecorator.new(field).new_application_data(self)
                      end
  end
end
