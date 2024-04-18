# frozen_string_literal: true

module ServiceSubscriptionRepresenter
  include ThreeScale::JSONRepresenter
  wraps_resource :service_subscription

  property :id
  property :plan_id
  property :user_account_id
  property :created_at
  property :updated_at
  property :state
  property :paid_until
  property :trial_period_expires_at
  property :setup_fee
  property :type
  property :variable_cost_paid_until
  property :tenant_id
  property :service_id
  property :accepted_at
end
