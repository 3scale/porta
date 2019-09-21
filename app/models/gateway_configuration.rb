# frozen_string_literal: true

class GatewayConfiguration < ApplicationRecord
  JWT_CLAIM_ATTRIBUTES = %i[jwt_claim_with_client_id jwt_claim_with_client_id_type].freeze
  ATTRIBUTES = JWT_CLAIM_ATTRIBUTES

  JWT_CLAIM_WITH_CLIENT_ID_TYPES = %w[plain liquid].freeze

  belongs_to :proxy, inverse_of: :gateway_configuration, touch: true
  store :settings, accessors: ATTRIBUTES, coder: JSON

  validates :jwt_claim_with_client_id_type, inclusion: { in: JWT_CLAIM_WITH_CLIENT_ID_TYPES, allow_nil: true}
  validates :jwt_claim_with_client_id, :jwt_claim_with_client_id_type, presence: {if: :jwt_claim_any?}

  def self.accessors
    ATTRIBUTES.flat_map {|attr| [attr, "#{attr}="] }
  end

  protected

  def jwt_claim_any?
    JWT_CLAIM_ATTRIBUTES.any? { |attr| public_send(attr).present? }
  end
end
