# frozen_string_literal: true

class BackendApiConfig < ApplicationRecord
  include Backend::ModelExtensions::BackendApiConfig

  default_scope -> { order(id: :asc) }
  belongs_to :service, inverse_of: :backend_api_configs
  belongs_to :backend_api, inverse_of: :backend_api_configs

  include ThreeScale::Search::Scopes

  self.allowed_sort_columns = %w[backend_apis.name backend_apis.private_endpoint backend_api_config.path]
  self.default_sort_column = 'backend_apis.name'
  self.default_sort_direction = :asc

  attribute :path, ActiveRecord::Type::StringNotNil.new

  has_many :backend_api_metrics, through: :backend_api, source: :metrics

  validates :service_id, :backend_api_id, presence: true
  validates :backend_api_id, uniqueness: { scope: :service_id }
  validates :path, uniqueness: { scope: :service_id, case_sensitive: false }
  validates :path, length: { in: 0..255, allow_nil: false }, path: true

  scope :with_subpath, -> do
    common_query = where.not(path: '/')
    System::Database.oracle? ? common_query.where('path is NOT NULL') : common_query.where.not(path: '')
  end

  delegate :private_endpoint, to: :backend_api

  def path=(value)
    super(StringUtils::StripSlash.strip_slash(value))
  end
end
