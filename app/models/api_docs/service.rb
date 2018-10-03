# encoding: utf-8
class ApiDocs::Service < ApplicationRecord
  CURRENT_SWAGGER_VERSION = 2

  include SystemName
  extend System::Database::Scopes::IdOrSystemName

  belongs_to :account, required: true
  belongs_to :service, class_name: '::Service'

  attr_accessible :account, :body, :name, :description, :published, :skip_swagger_validations
  attr_readonly :system_name

  self.table_name = "api_docs_services"
  has_system_name uniqueness_scope: :account_id

  validates :name, :body, presence: true
  validates :name, :system_name, :base_path, :swagger_version, length: { maximum: 255 }
  validates :description, length: { maximum: 65535 }
  validates :body, length: { maximum: 4294967295, allow_blank: true }
  validate :service_belongs_to_account, if: -> { service_id.present? && service_id_changed? }

  scope :published, -> { where(published: true) }
  scope :accessible, -> { joining { service.outer }.where.has { (service_id == nil) | (service.state != ::Service::DELETE_STATE) } }

  before_save :set_default_values
  before_save :prepare_base_path_notify

  after_commit :notify_new_base_path, if: :should_notify?

  validates_with ThreeScale::Swagger::Validator
  validates_with ThreeScale::LocalhostValidator, attributes: :base_path

  def self.with_system_names(system_names)
    unless system_names.empty?
      where system_name: system_names
    else
      all
    end
  end

  # This is for ActiveDocs specs
  def self.for(account)
    services = account.api_docs_services.published

    { :host => account.domain,
      :apis => services.map { |service| ApiDocs::Service.spec_for(service)} }
  end

  # This is for ActiveDocs specs
  def self.spec_for(service)
    { :name        => service.name,
      :system_name => service.system_name,
      :description => service.description,
      :path        => "/api_docs/services/#{service.id}.json" }
  end

  def base_path
    specification.base_path || self[:base_path]
  end

  def swagger_version
    self[:swagger_version] or specification.swagger_version
  end

  def needs_swagger_update?
    self.swagger_version.to_i < CURRENT_SWAGGER_VERSION
  end

  def to_xml(options = {})
    builder = options[:builder] || ThreeScale::XML::Builder.new

    builder.api_doc do |xml|
      xml.id_ id
      xml.system_name system_name
      xml.name name
      xml.description description
      xml.published published

      xml.body body

      xml.created_at created_at
      xml.updated_at updated_at
    end

    builder.to_xml
  end

  def body=(string_or_io)
    super(string_or_io.try(:read) || string_or_io) and @_spec = nil
  end

  # This is the body JSON parsed
  def specification
    @_spec ||= ThreeScale::Swagger::Specification.new(self.body)
  end

  private

  def service_belongs_to_account
    return true if account.services.accessible.where(id: service_id).exists?
    errors.add(:base, :service_account_mismatch)
  end

  def should_notify?
    NotificationCenter.new(self).enabled?
  end

  # before save callback that sets defaults for swagger_version and base_path
  def set_default_values
    self.swagger_version = specification.swagger_version
    self.base_path       = specification.base_path
  end

  def prepare_base_path_notify
    @send_notification = true if new_base_path?
  end

  def new_base_path?
    self.class.where({:base_path => base_path}).limit(1).empty?
  end

  def notify_new_base_path
    ApiDocs::Mailer.new_path_notification(self).deliver_now if @send_notification
    @send_notification = nil
  end

end
