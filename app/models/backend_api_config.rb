# frozen_string_literal: true

class BackendApiConfig < ApplicationRecord
  include Backend::ModelExtensions::BackendApiConfig

  default_scope -> { order(id: :asc) }
  belongs_to :service, inverse_of: :backend_api_configs
  belongs_to :backend_api, inverse_of: :backend_api_configs

  attribute :path, ActiveRecord::Type::StringNotNil.new

  has_many :backend_api_metrics, through: :backend_api, source: :metrics

  validates :service_id, :backend_api_id, presence: true
  validates :path, uniqueness: { scope: :service_id, case_sensitive: false }
  validates :path, length: { in: 0..255, allow_nil: false }, path: true
  validate :validate_service_and_backend_api_belong_to_the_same_tenant

  scope :with_subpath, (lambda do
    common_query = where.not(path: '/')
    System::Database.oracle? ? common_query.where('path is NOT NULL') : common_query.where.not(path: '')
  end)

  delegate :private_endpoint, to: :backend_api

  def path=(value)
    super(StringUtils::StripSlash.strip_slash(value))
  end

  private

  def validate_service_and_backend_api_belong_to_the_same_tenant
    return if service.blank? || backend_api.blank?
    return if service.account_id == backend_api.account_id
    errors.add(:service, 'must belong to the same tenant as the backend api')
  end
end
