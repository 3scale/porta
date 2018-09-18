# frozen_string_literal: true


class AddMissingTenantIdColumns < ActiveRecord::Migration
  # NOT INCLUDED: backend_events, partners, user_sessions

  TABLES = %w[access_tokens
  event_store_events
  go_live_states
  notification_preferences
  onboardings
  payment_details
  payment_gateway_settings
  service_tokens
  sso_authorizations
].freeze

  def change
    TABLES.each do |table_name|
      change_table table_name do |t|
        t.column :tenant_id, :integer, limit: 8
      end
    end
  end
end
