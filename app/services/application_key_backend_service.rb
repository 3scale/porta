# frozen_string_literal: true

module ApplicationKeyBackendService
  module_function
  extend ApplicationAssociationBackendService

  def reflection_name
    :application_keys
  end

  def pisoni_class
    ThreeScale::Core::ApplicationKey
  end
end
