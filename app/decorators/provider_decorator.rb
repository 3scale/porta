# frozen_string_literal: true

class ProviderDecorator < ApplicationDecorator
  self.include_root_in_json = false

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
