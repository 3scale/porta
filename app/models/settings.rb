class Settings < ApplicationRecord
  include Symbolize
  belongs_to :account, inverse_of: :settings

  audited allow_mass_assignment: true

  attr_protected :account_id, :tenant_id, :product, :audit_ids, :sso_key

  validates :product, inclusion: { in: %w[connect enterprise].freeze }
  validates :change_account_plan_permission, :change_service_plan_permission, inclusion: { in: %w[request none credit_card request_credit_card direct].freeze }
  validates :bg_colour, :link_colour, :text_colour, :menu_bg_colour, :link_label, :link_url, :menu_link_colour, :token_api,
            :content_bg_colour, :tracker_code, :favicon, :plans_tab_bg_colour, :plans_bg_colour, :content_border_colour,
            :cc_privacy_path, :cc_terms_path, :cc_refunds_path, :change_service_plan_permission, :spam_protection_level,
            :authentication_strategy, :janrain_api_key, :janrain_relying_party, :cms_token, :cas_server_url, :sso_key,
            :admin_bot_protection_level, :sso_login_url, length: { maximum: 255 }

  symbolize :spam_protection_level, :admin_bot_protection_level

  include Switches

  before_create :generate_sso_key
  before_create :set_forum_enabled

  alias provider account

  def self.columns
    super.reject {|column| /\Aheroku_(id|name)|log_requests_switch\Z/ =~ column.name }
  end

  def self.non_null_columns_names
    columns.select { |column| !column.null }.map(&:name)
  end

  def approval_required_editable?
    not_custom_account_plans.size == 1
  end

  def approval_required_disabled?
    not_custom_account_plans.size > 1 && account_plans_ui_visible?
  end

  def assign_attributes(attrs, options = {})
    super(sanitize_attributes(attrs), options)
  end

  def update(attrs)
    update_approval_required(attrs) if approval_required_editable?

    super(attrs)
  end

  def set_forum_enabled
    self.forum_public = false if account

    true
  end

  def account_approval_required
    @account_approval_required = default_account_plan.approval_required
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

  def password_login_allowed?
    true
  end

  def spam_protection_level
    # `:auto` is the old 'Suspicious only' mode which is deprecated and replaced by `:captcha`.
    # We accept it only for backwards compatibility with clients still having 'auto' in the DB
    level = super.to_sym
    level == :auto ? :captcha : level
  end

  # To avoid a dangerous DB migration, we allow empty values in the column and assume empty means `:none`
  def admin_bot_protection_level
    super&.to_sym || :none
  end

  delegate :provider_id_for_audits, :to => :account, :allow_nil => true

  private

  def not_custom_account_plans
    @not_custom_account_plans ||= provider.account_plans.not_custom
  end

  def default_account_plan
    provider.account_plans.default || not_custom_account_plans.first!
  end

  def update_approval_required(attrs)
    value = attrs.delete(:account_approval_required)
    default_account_plan.update_attribute(:approval_required, value) unless value.to_s.empty?
  end

  # Remove attributes with empty strings and nil for non-null columns
  def sanitize_attributes(attrs)
    attrs.reject { |key, value| self.class.non_null_columns_names.include?(key.to_s) && value.to_s.empty? }
  end
end
