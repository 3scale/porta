# frozen_string_literal: true

module ReferrerFilterBackendService
  module_function
  extend ApplicationAssociationBackendService

  def reflection_name
    :referrer_filters
  end

  def pisoni_class
    ThreeScale::Core::ApplicationReferrerFilter
  end
end
