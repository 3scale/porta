# frozen_string_literal: true

class BackendApiConfig < ApplicationRecord

  default_scope -> { order(id: :asc) }
  belongs_to :service, inverse_of: :backend_api_configs
  belongs_to :backend_api, inverse_of: :backend_api_configs

  validates :path, length: { in: 0..255, allow_nil: false }, path: true

  def path=(value)
    super(value.to_s.reverse.chomp("/").reverse.chomp("/"))
  end
end
