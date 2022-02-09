# frozen_string_literal: true

class CMS::EmailTemplate < CMS::Template

  attr_accessible :system_name, :draft, :published, :headers # do not do drafts

  validates :system_name, presence: true
  validates :current, presence: true
  validates :system_name, uniqueness: { scope: %i[provider_id], allow_blank: true }
  validate :headers_formats

  class_attribute :templates_path

  def self.reset_templates_path!
    self.templates_path = Rails.root.join('app', 'views', 'emails')
  end

  BUYER_BILLING_TEMPLATES = %w[
    account_messenger_expired_credit_card_notification_for_buyer
    invoice_messenger_upcoming_charge_notification
    invoice_messenger_successfully_charged
    invoice_messenger_unsuccessfully_charged_for_buyer
    invoice_messenger_unsuccessfully_charged_for_buyer_final
    cinstance_messenger_expired_trial_period_notification
    service_contract_messenger_expired_trial_period_notification
  ].freeze

  PROVIDER_TEMPLATES = %w[
    account_messenger_expired_credit_card_notification_for_provider
    alert_messenger_limit_alert_for_provider
    alert_messenger_limit_violation_for_provider
    invoice_messenger_unsuccessfully_charged_for_provider
    invoice_messenger_unsuccessfully_charged_for_provider_final
    account_messenger_invoices_to_review
    account_messenger_new_signup
    account_messenger_plan_change_request
    cinstance_messenger_contract_cancellation
    cinstance_messenger_new_application
    cinstance_messenger_plan_change
    service_contract_messenger_contract_cancellation
    service_contract_messenger_new_contract
    service_contract_messenger_plan_change
    data_export
  ].freeze

  reset_templates_path!

  EMAIL_ADDRESS_FORMAT = /\s*#{User::RE_EMAIL_NAME}@#{User::RE_DOMAIN_HEAD}#{User::RE_DOMAIN_TLD}/i
  EMAIL_WITH_NAME_FORMAT = /.+?<(#{EMAIL_ADDRESS_FORMAT})>/i
  EMAIL_FORMAT = /(?:(#{EMAIL_ADDRESS_FORMAT})|#{EMAIL_WITH_NAME_FORMAT})\s*/i
  EMAILS_FORMAT = /\A#{EMAIL_FORMAT}(,\s*#{EMAIL_FORMAT})*\Z/i

  class HashOrParameters < ::ActiveRecord::Coders::YAMLColumn
    def load(string)
      obj = super(string)
      obj.respond_to?(:to_unsafe_h) ? obj.to_unsafe_h : obj.to_h if obj
    end

    def dump(object)
      return object if object.is_a?(String) && assert_valid_value(load(object), action: "dump")
      obj = object.respond_to?(:to_unsafe_h) ? object.to_unsafe_h : object.to_h if object
      super(obj)
    end

    def assert_valid_value(obj, action:)
      obj.is_a?(Hash) || obj.is_a?(ActionController::Parameters) || super
    end
  end

  serialize :options, HashOrParameters.new(:options, Hash)

  attr_accessor :file

  def name
    default = system_name ? system_name.humanize : '(no name)'
    I18n.translate(system_name, scope: %i[cms email_template], default: default)
  end

  def description
    I18n.translate(system_name, scope: %i[cms email_template_description], default: 'No description.')
  end

  def headers
    @headers ||= Headers.new(self[:options]) do |hash|
      options_will_change!
      # this is for consitency
      # when you #inspect EmailTemplate, you should see updated headers
      self[:options] = hash
    end
  end

  def content_type
    "application/x-liquid-template"
  end

  def mime_type
    super or Mime['text/plain']
  end

  def headers=(val)
    @headers = nil
    self[:options] = val.respond_to?(:to_unsafe_h) ? val.to_unsafe_h : val
  end

  def reload(*)
    @headers = nil
    super
  end

  def published
    super or file&.read
  end

  def save(*)
    publish if draft?
    super
  end

  def headers_formats
    headers.to_hash.dup.each do |name, value|

      field = "headers.#{name}"
      next if value.blank?

      case name

      when :bcc, :cc, :reply_to
        errors.add(field, :invalid_email) if value !~ EMAILS_FORMAT

      when :from
        # extract all email addresses from field
        next unless email = value.scan(EMAIL_FORMAT).flatten.compact.presence

        # fail if user passed multiple addresses
        next errors.add(field, :invalid_email) unless email.one?

        # user passed email, validate its domain
        domain = provider.from_email.split('@').last

        errors.add(field, :wrong_domain) unless email.join.split('@').last == domain
      end
    end
  end

  # This is for assert_invalid method, it pretty prints invalid attributes
  def method_missing(method, *args)
    if method.to_s =~ /\Aheaders\.(.+)$/
      headers.send(Regexp.last_match(1), *args)
    else
      super
    end
  end

  private
  def set_rails_view_path
    self.rails_view_path = "emails/#{system_name}"
  end

  class << self

    def new_by_system_name(system_name, file = nil)
      new do |template|
        template.system_name = system_name
        template.file = templates_path.join(system_name + ".text.liquid")
      end
    end

    def default_system_names
      @default_system_names ||= Pathname.glob(templates_path.join("*.liquid")).map { |file| file.basename('.text.liquid').to_s }.sort
    end
  end


  class Headers < OpenStruct
    delegate :to_hash, :to => :@table

    # block is used as callback when setter method is called
    # callback is actualy called before value is set :/
    def initialize(hash = {}, &block)
      @block = block
      super
    end

    def to_yaml
      # do not store empty values
      @table.reject {|k,v| v.blank?}
    end

    def from_email(base_email)
      return if from.blank?

      if from =~ /\A#{CMS::EmailTemplate::EMAIL_FORMAT}\Z/
        from
      else
        %("#{from}" <#{base_email}>)
      end
    end

    def to_email_headers(base_email)
      from = from_email(base_email)
      hash = to_hash.symbolize_keys.reject { |k,v| v.blank? }
      hash[:from] = from if from
      hash
    end

    private
    def modifiable
      @block&.call(to_hash)
      super
    end
  end

  module ExtensionCore
    def template_headers(template)
      return if !template.respond_to?(:headers) || !template.headers

      template.headers.to_email_headers(template.provider.from_email)
    end
  end

  module MailerExtension
    class DoubleAssignError < StandardError; end

    extend ActiveSupport::Concern

    included do
      prepend(Module.new do
                protected

                def mail(headers, &block)
                  if @provider_account
                    headers[:template_path] ||= 'emails'
                    prepend_view_path Liquid::Template::Resolver.instance(@provider_account)

                    headers[::Message::APPLY_ENGAGEMENT_FOOTER]= @provider_account.should_apply_email_engagement_footer?
                  else
                    Rails.logger.warn { "#{caller[2]} does not have provider_account set, falling back to filesytem templates" }
                  end

                  super(headers, &block)
                end

                def render(options)
                  template = options.fetch(:template)
                  apply_headers!(template.record) if template.respond_to?(:record)
                  super(options)
                end
      end)

      attr_reader :provider_account
      alias_method :provider, :provider_account

      layout false
    end

    include ExtensionCore

    protected

    def provider_account=(provider_account)
      raise DoubleAssignError if @provider_account

      @provider_account = provider_account
    end

    def apply_headers!(template)
      headers = template_headers(template)

      headers.each do |key, value|
        @_message[key] = value
      end
    end

    def prepare_liquid_template(template)
      template.registers[:mail] = @_message
    end
  end

  module MessageExtension
    include ExtensionCore

    def apply_headers(template)
      headers = template_headers(template)
      update_headers(headers)
    end

    def update_headers(hash)
      unknown = hash.slice!(*allowed_methods).stringify_keys

      self.headers = headers.merge(unknown)

      # just allowed methods
      hash.each do |key, val|
        send("#{key}=", val)
      end
    end

    private
    def allowed_methods
      [:subject]
    end
  end

  module ProviderAssociationExtension
    def all_new_and_overridden
      system_names = default_system_names
      provider = try(:proxy_association)&.owner

      if provider&.provider_can_use?(:new_notification_system)
        system_names -= PROVIDER_TEMPLATES
        system_names -= BUYER_BILLING_TEMPLATES if provider.master_on_premises?
      end

      templates = where(system_name: system_names).index_by(&:system_name)

      system_names.map do |system_name|
        templates.fetch(system_name) { new_by_system_name(system_name) }
      end
    end

    def find_by_name(name)
      find_by(system_name: name) or find_default_by_name(name)
    end

    def find_default_by_name(name)
      if file = find_file_template(name)
        new(:system_name => name, :published => file, # .read
            :provider => respond_to?(:proxy_association) ? proxy_association.owner : nil)
      end
    end

    def find_file_template(name)
      root = CMS::EmailTemplate.templates_path
      files = [root.join(name + '.text.liquid'), root.join(name + '.liquid')]

      files.each do |file|
        return file.read if file.exist?
      end

      nil
    end
  end
end
