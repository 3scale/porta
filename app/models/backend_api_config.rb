# frozen_string_literal: true

class BackendApiConfig < ApplicationRecord
  belongs_to :service, inverse_of: :backend_api_configs
  belongs_to :backend_api, inverse_of: :backend_api_configs

  validates :path, path: true, length: { maximum: 255 }

  def path=(value)
    super(value.to_s.reverse.chomp("/").reverse.chomp("/"))
  end
end
