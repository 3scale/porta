# frozen_string_literal: true

module Signup
  class SignupParams
    def initialize(user_attributes: {}, account_attributes: {}, plans: [], defaults: {}, validate_fields: true)
      @attributes = {user: user_attributes, account: prepare_account_attributes(account_attributes)}
      @plans = plans
      @defaults = defaults
      @validate_fields = validate_fields
    end
    attr_reader :plans, :defaults, :attributes, :validate_fields

    private

    def prepare_account_attributes(attributes)
      attributes ||= {}
      attributes.delete('name') if attributes['org_name'].present?
      attributes
    end
  end
end
