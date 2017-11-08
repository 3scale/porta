require 'simple_layout'

class Settings < ApplicationRecord
  extend Symbolize
  belongs_to :account, inverse_of: :settings

  audited allow_mass_assignment: true

  attr_protected :account_id, :tenant_id, :product, :audit_ids, :sso_key, :heroku_id, :heroku_name

  validates :product, inclusion: { in: %w(connect enterprise).freeze }
  validates :change_account_plan_permission, inclusion: { in: %w(request none credit_card request_credit_card direct).freeze }

  symbolize :spam_protection_level

  SWITCHES = %i[ end_users account_plans service_plans finance require_cc_on_signup
                 multiple_services multiple_applications multiple_users skip_email_engagement_footer
                 groups branding web_hooks iam_tools ].freeze
  THREESCALE_VISIBLE_SWITCHES = %i[
    finance branding end_users groups skip_email_engagement_footer web_hooks require_cc_on_signup
  ].freeze
  MULTISERVICES_MAX_SERVICES = 3

  before_create :generate_sso_key
  before_create :set_forum_enabled

  alias provider account

  def self.columns
    super.reject { |column| column.name == 'log_requests_switch'}
  end

  def self.hide_basic_switches?
    Rails.configuration.three_scale.hide_basic_switches
  end

  def self.basic_enabled_switches
    if hide_basic_switches?
      %i(multiple_services multiple_applications multiple_users).freeze
    else
      [].freeze
    end
  end

  def self.basic_disabled_switches
    if hide_basic_switches?
      %i(skip_email_engagement_footer).freeze
    else
      [].freeze
    end
  end

  def self.basic_hidden_switches
    basic_disabled_switches
  end

  # Using a constant here seems weird as it depends on some parameters
  def globally_denied_switches
    [
      account.master_on_premises? ? :finance : nil
    ].compact
  end

  def approval_required_editable?
    not_custom_account_plans.size == 1
  end

  def approval_required_disabled?
    not_custom_account_plans.size > 1 && account_plans_ui_visible?
  end

  def update_attributes(attributes)
    if approval_required_editable?
      value = attributes.delete(:account_approval_required) || false
      account_plan = provider.account_plans.default || not_custom_account_plans.first!
      account_plan.update_attribute(:approval_required, value)
    end

    super(attributes)
  end

  def set_forum_enabled
    if account
      self.forum_public = self.forum_enabled = !!account.provider_can_use?(:forum)
    end

    true
  end

  def account_approval_required
    account_plan = provider.account_plans.default || not_custom_account_plans.first!
    @account_approval_required = account_plan.approval_required
  end

  def account_approval_required=(value)
    @account_approval_required = value
  end

  def generate_sso_key
    self.sso_key = ThreeScale::SSO.generate_sso_key if account && account.provider?
  end

  def authentication_strategy
    ActiveSupport::StringInquirer.new(super)
  end

  def cms_token!
    unless cms_token?
      self.update_attribute(:cms_token, SecureRandom.hex(16))
    end
    cms_token
  end

  def has_privacy_policy?
    !privacy_policy.blank?
  end

  def has_refund_policy?
    !refund_policy.blank?
  end

  def enterprise?
    self.product == 'enterprise'
  end

  # @return [Hash<Symbol,Settings::Switch>]
  def switches
    Hash[ SWITCHES.map{ |switch_name| [ switch_name, send(switch_name) ] } ]
  end

  class Switch
    delegate :hidden?, :visible?, :denied?, to: :status

    attr_reader :name, :settings

    def initialize(settings, name)
      @settings = settings
      @name = name
    end

    def status
      # it has to be read_attribute - calling the method would cause
      # return a Switch object
      ActiveSupport::StringInquirer.new(@status || update_status)
    end

    def hideable?
      !globally_denied? && Settings.basic_hidden_switches.exclude?(name.to_sym)
    end

    def allowed?
      not denied?
    end

    def hide!
      if visible?
        @settings.send("hide_#{@name}!")
      end
    ensure
      update_status
    end

    def show!
      if hidden?
        @settings.send("show_#{@name}!")
      end
    ensure
      update_status
    end

    def allow
      @settings.send("allow_#{@name}")
    ensure
      update_status
    end

    def deny
      @settings.send("deny_#{@name}")
    ensure
      update_status
    end

    def reload
      @settings = @settings.clone.reload
      update_status
      self
    end

    def globally_denied?
      false
    end

    private

    def update_status
      @status = @settings.read_attribute("#{@name}_switch").to_s
    end

  end

  class SwitchDenied < Switch
    def allowed?
      false
    end

    def hidden?
      false
    end

    def visible?
      false
    end

    def denied?
      true
    end

    def hide!
      false
    end

    def show!
      false
    end

    def allow
      false
    end

    def deny
      true
    end

    def globally_denied?
      true
    end
  end

  # Switches State Machine
  #
  #
  #    +--------------+	                         +--------------+
  #    |              +                          |              |
  #    | Visible      |                          |   DENIED     |
  #    |              |       deny               |              |
  #    |              o------------------------->+              |
  #    +---+-----+----+			                     +-----+--------+
  # 	   |	 |				                               ^  |
  # 	   |	 | hide/show		                         |  |
  # 	   |	 |			                                 |  |
  # 	+--+-----+----+	         deny          	       |  |
  # 	|             |-------------------------------    |
  # 	|  Hidden     |          allow                    |
  # 	|             |<-----------------------------------
  # 	|             |
  # 	+-------------+
  #
  SWITCHES.each do |name|

    switch = "#{name}_switch"

    attr_protected switch

    state_machine switch, initial: :denied, namespace: name do
      before_transition do |settings|
        unless settings.account.provider?
          raise Account::ProviderOnlyMethodCalledError, "cannot change state of #{name} of #{settings.inspect}"
        end
      end

      state :denied, :hidden, :visible

      event :hide do
        transition visible: :hidden
      end

      event :show do
        transition hidden: :visible
      end

      event :deny do
        transition [:hidden, :visible] => :denied
      end

      event :allow do
        transition denied: :hidden
      end
    end

    define_method(name) do
      if globally_denied_switches.include?(name.to_sym)
        SwitchDenied.new(self, name)
      else
        Switch.new(self, name)
      end
    end
  end

  finance = state_machines['finance_switch']

  finance.after_transition to: :denied, from: [ :hidden, :visible ] do |settings|
    settings.account.billing_strategy.destroy if settings.account.billing_strategy
  end

  finance.after_transition to: [ :visible, :hidden ], from: [ :denied ] do |settings|
    unless settings.account.billing_strategy
      account = settings.account
      account.billing_strategy = Finance::PostpaidBillingStrategy.create(account: account, currency: 'USD')
      account.save!
    end
  end

  state_machines['multiple_applications_switch'].after_transition to: [ :visible, :hidden ], from: [ :denied ] do |settings|
    SimpleLayout.new(settings.account).create_multiapp_builtin_pages!
  end

  state_machines['multiple_services_switch'].after_transition to: [ :visible, :hidden ], from: [ :denied ] do |settings|
    SimpleLayout.new(settings.account).create_multiservice_builtin_pages!

    settings.account.update_provider_constraints_to(
      { max_services: MULTISERVICES_MAX_SERVICES },
      'Upgrading max_services because of switch is enabled.'
    )
  end

  state_machines['service_plans_switch'].after_transition to: [ :visible, :hidden ], from: [ :denied ] do |settings|
    SimpleLayout.new(settings.account).create_service_plans_builtin_pages!
  end

  def visible_ui?(switch)
    attribute = "#{switch}_ui_visible"
    if has_attribute?(attribute)
      self[attribute]
    elsif switch == :require_cc_on_signup # visible only for existing providers as of 2016-07-05
      account.provider_can_use?(switch)
    else
      true
    end
  end

  def password_login_allowed?
    true
  end

  protected

  delegate :provider_id_for_audits, :to => :account, :allow_nil => true

  private

  def not_custom_account_plans
    @not_custom_account_plans ||= provider.account_plans.not_custom
  end
end
