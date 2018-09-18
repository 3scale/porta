# frozen_string_literal: true

class AuthenticationProviderRepresenter < ThreeScale::Representer
  include ThreeScale::JSONRepresenter
  include Roar::XML
  wraps_resource :authentication_provider

  property :id
  property :kind
  property :account_type
  property :name
  property :system_name
  property :client_id
  property :client_secret
  property :site
  property :token_url
  property :user_info_url
  property :authorize_url
  property :skip_ssl_certificate_verification
  property :automatically_approve_accounts
  property :branding_state
  property :account_id
  property :username_key
  property :identifier_key
  property :trust_email
  property :published
  property :created_at, exec_context: :decorator
  property :updated_at, exec_context: :decorator
  property :callback_url, exec_context: :decorator

  def callback_url
    return unless represented.callback_account == represented.account
    represented.try(:sso_integration_callback_url)
  end

  def created_at
    self.class.timestamp(represented.created_at)
  end

  def updated_at
    self.class.timestamp(represented.updated_at)
  end

  def self.timestamp(time_object)
    TimeDelegator.new(time_object) if time_object.present?
  end

  class TimeDelegator < SimpleDelegator
    def to_s
      super(:iso8601)
    end
  end
end
