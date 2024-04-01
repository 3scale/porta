# frozen_string_literal: true

module ServiceContractRepresenter
  include ThreeScale::JSONRepresenter
  wraps_resource

  property :id
  property :plan_id
  property :user_account_id
  property :user_key
  property :provider_public_key
  property :created_at
  property :updated_at
  property :state
  property :description
  property :paid_until
  property :application_id
  property :name
  property :trial_period_expires_at
  property :setup_fee
  property :type
  property :redirect_url
  property :variable_cost_paid_until
  property :extra_fields
  property :tenant_id
  property :create_origin
  property :first_traffic_at
  property :first_daily_traffic_at
  property :service_id
  property :accepted_at
end
