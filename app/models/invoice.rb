require_dependency 'pdf/finance/invoice_report_data'
require_dependency 'pdf/finance/invoice_generator'

require_dependency 'month'

# TODO: add uniqueness check on provider/buyer/period scope
#
class Invoice < ApplicationRecord
  %I[due_on period issued_on last_charging_retry].each do |attr|
    attribute attr, :date
  end

  MAX_CHARGE_RETRIES = 3
  DECIMALS   = 2
  CHARGE_PRECISION   = 2

  enum creation_type: {manual: 'manual', background: 'background'}

  include AfterCommitQueue
  audited :allow_mass_assignment => true
  has_associated_audits

  class InvalidInvoiceStateException < RuntimeError; end

  # Default gap between issued_on and due_on dates
  ISSUE_AND_DUE_DEFAULT_DELAY = 2.days

  belongs_to :buyer_account, :class_name => 'Account'
  belongs_to :provider_account, :class_name => 'Account'

  delegate :s3_provider_prefix, to: :provider_account

  alias provider provider_account
  alias buyer buyer_account

  has_many :paid_line_items, -> { where(invoices: {state: 'paid'}).includes(:invoice).references(:invoice) }, class_name: 'LineItem'
  has_many :line_items, -> { oldest_first }, dependent: :destroy, inverse_of: :invoice

  has_many :payment_transactions, -> { oldest_first }, dependent: :nullify, inverse_of: :invoice
  has_many :payment_intents, dependent: :destroy, inverse_of: :invoice

  has_attached_file :pdf, url: ':url_root/:class/:id/:attachment/:style/:basename.:extension'
  do_not_validate_attachment_file_type :pdf

  attr_accessible :provider_account, :buyer_account, :friendly_id, :period

  validates :provider_account, :buyer_account, :friendly_id, presence: true
  validates :period, presence: { :message => 'Billing period format should be YYYY-MM' }

  validates :friendly_id, format: { with: /\A\d{4}(-\d{2})?-\d{8}\Z/,
                                    message: 'format should be YYYY-MM-XXXXXXXX or YYYY-XXXXXXXX',
                                    if: :friendly_id_changed?
                                  }

  validates :from_address_name, :from_address_line1, :from_address_line2, :from_address_city, :from_address_region,
            :from_address_state, :from_address_country, :from_address_zip, :from_address_phone, :to_address_name,
            :to_address_line1, :to_address_line2, :to_address_city, :to_address_region, :to_address_state,
            :to_address_country, :to_address_zip, :to_address_phone, length: {maximum: 255}

  default_scope -> { order('invoices.created_at DESC') }

  # 'conditions' is a simple convenience method defined here ... see below
  scope :before, ->(month) { where('period < ?', month.beginning_of_month.to_date ) }
  scope :due, ->(time) { where(:due_on => time.to_date) }
  scope :due_on_or_before, ->(date) { where('due_on <= ?', date ) }
  scope :finalized_before, ->(date) { where("state='finalized' AND finalized_at <= ?", date) }

  # The month should be a YYYY-MM formated string.
  scope :by_month, ->(month) { where(:period => ::Month.parse_month(month)) }
  scope :by_year, ->(year) {  where.has { sift(:year, period) ==  year } }
  scope :by_month_number, ->(month) {  where.has { sift(:month_number, period) == month } }

  # Can use * as wildcard in friendly id
  scope :by_number, ->(number) {
    number = number.dup
    if number.tr!('*', '%')
      where('friendly_id LIKE ?', number)
    else
      where(:friendly_id => number)
    end
  }

  scope :without_ids, ->(invoice) { where('id <> ?', invoice.id) }
  scope :by_state, ->(state) { where(:state => state.to_s) }
  scope :by_buyer, ->(buyer) { where(:buyer_account_id => buyer.id) }
  scope :by_buyer_query, ->(query) { where(:buyer_account_id => Account.buyers.search_ids(query)) }
  scope :by_provider, ->(provider) { where(:provider_account_id => provider.id) }

  # the invoice has to be due and at least 3 days later than the last
  # automatic charging date to be automatically chargeable
  scope :chargeable, ->(now) {
    where.has do
      ((state == 'unpaid') | (state == 'pending')) &
        (due_on <= now) &
        ((last_charging_retry == nil) | (last_charging_retry <= (now - 3.days)))
    end
  }

  scope :opened, -> { where(:state => 'open') }
  scope :finalized, -> { where(:state => 'finalized') }
  scope :not_cancelled, -> { where("#{Invoice.table_name}.state <> 'cancelled'") }
  scope :not_frozen, -> { where("#{Invoice.table_name}.state = 'open' OR #{Invoice.table_name}.state = 'finalized'") }

  scope :visible_for_buyer, -> { where(state: ["pending", "unpaid", "paid", "failed"]) }
  scope :by_creation_type, ->(creation_type) { where(creation_type: Invoice.creation_types[creation_type]) }

  scope :with_normalized_friendly_id, ->(numbering_period, month) {
    case numbering_period
    when 'monthly'
      by_year(month.begin.year).by_month_number(month.begin.month).where.has { func(:length, friendly_id) == 16 }
    when 'yearly', nil
      by_year(month.begin.year).where.has { func(:length, friendly_id) == 13 }
    else raise "unknown numbering period: #{numbering_period}.inspect"
    end
      .reordering { func(:substr, friendly_id, -8).desc }
  }

  after_create :log_entry_created

  include ThreeScale::Search::Scopes

  self.allowed_sort_columns = %w{ friendly_id accounts.org_name period state }
  self.sort_columns_joins = {'accounts.org_name' => :buyer_account}
  self.allowed_search_scopes = [:number, :month, :month_number, :year, :state, :buyer_query]

  composed_of :from_address,
              :mapping => ThreeScale::Address.mapping('from_address'),
              :class_name => 'ThreeScale::Address'

  composed_of :to_address,
              :mapping => ThreeScale::Address.mapping('to_address'),
              :class_name => 'ThreeScale::Address'

  state_machine :initial => :open do
    state :open
    state :finalized
    state :pending
    state :unpaid
    state :paid
    state :failed
    state :cancelled

    state :open, :finalized do
      def from
        provider.address_for_invoice
      end

      def to
        buyer.address_for_invoice
      end

      def currency
        provider.try!(:currency)
      end

      def fiscal_code
        (buyer && (buyer.fiscal_code || '')) || ''
      end

      def vat_code
        (buyer && (buyer.vat_code || '')) || ''
      end
    end

    state all - [ :open, :finalized ] do
      def from
        self.from_address
      end

      def to
        self.to_address
      end

      def currency
        self[:currency]
      end

      def fiscal_code
        self[:fiscal_code] || ''
      end

      def vat_code
        self[:vat_code] || ''
      end
    end

    before_transition :to => :finalized do |invoice|
      invoice.finalized_at = Time.now.utc
    end

    # Mental note:
    #
    # TL;DR - Data of the invoices closed before the Rails3 deploy are
    # not necessarily correct (in sync with the PDFs).
    #
    # Why? Because BEFORE having the freezing implemented, addresses
    # and vat_stuff (tm) was changing dynamically. Now was all
    # frozen at the moment of migration so they should be 'more correct'
    # although not perfect. Invoices issued AFTER the Rails3 deploy
    # can be considered reliable.
    #
    before_transition :to => :pending do |invoice|
      raise "Cannot issue invoice (#{invoice.id}) with a deleted buyer" unless invoice.buyer

      invoice.vat_rate = invoice.buyer.vat_rate
      invoice.vat_code = invoice.buyer.vat_code || ''
      invoice.fiscal_code = invoice.buyer.fiscal_code || ''
      invoice.currency = invoice.provider.currency

      # freezes all the available information
      invoice.from_address = invoice.provider.address_for_invoice

      invoice.to_address = invoice.buyer.address_for_invoice

      invoice.issued_on = Time.now.utc.to_date
      invoice.due_on = invoice.issued_on + ISSUE_AND_DUE_DEFAULT_DELAY

      invoice.generate_pdf!
    end

    before_transition :to => :paid do |invoice|
      invoice.paid_at = Time.now.utc
    end

    master_invoice = ->(invoice) { invoice.provider.master? }

    after_transition to: :paid, do: :notify_buyer_about_payment

    after_transition to: :paid, if: master_invoice do |invoice, _|
      account = invoice.buyer_account
      bought_plan = account.bought_plan

      ThreeScale::Analytics.track_account(account, 'Charged Invoice',
                                  {
                                      plan: bought_plan.name,
                                      period: invoice.period.to_s,
                                      revenue: invoice.cost.to_f
                                  })
    end

    after_transition if: master_invoice do |invoice, _|
      account = invoice.buyer_account
      ThreeScale::Analytics::Salesforce.new(account).update_invoice_status(invoice)
    end

    event :finalize do
      transition :open => :finalized
    end

    event :issue do
      transition [ :open, :finalized ] => :pending
    end

    event :mark_as_unpaid do
      transition :pending => :unpaid
    end

    event :pay do
      transition [ :unpaid, :pending, :failed ] => :paid
    end

    event :fail do
      transition :unpaid => :failed
    end

    event :cancel do
      transition [ :open, :finalized, :pending, :unpaid, :failed ] => :cancelled
    end

  end

  # this scope has to be defined after the state_machine definition, or
  # demons are released (create invoice crashes)
  scope :unresolved, -> { where(:state => ['open', 'finalized', 'pending', 'unpaid']) }

  private :issue!

  # ---- Instance methods ----

  def log_entry_created
    LogEntry.log( :info, "Invoice created for #{buyer_account.org_name} for period #{period}", provider_account, buyer_account)
  end

  def name
    self.period.begin.strftime('%B, %Y')
  end

  def cinstance
    buyer_account.bought_cinstances.provided_by(provider_account).first
  end

  def to_xml(options = {})
    markup = Finance::Builder::XmlMarkup.new(options)
    markup.invoice!(self)
    markup.to_xml
  end

  def issued?
    !issued_on.nil?
  end

  def generate_pdf!
    data = Pdf::Finance::InvoiceReportData.new(self)
    self.pdf = Pdf::Finance::InvoiceGenerator.new(data).generate_as_attachment
    save(:validate => false)
  end

  def period
    unless @period
      attr = self[:period]
      @period = attr ? ::Month.new(attr) : nil
    end
    @period
  end

  def reload(*)
    @period = nil
    super
  end

  # vat_rate is updated by a buyer#after_save callback so the code
  # is the same both before and after issuing (see Account#update_vat_rates)
  #
  before_create :set_vat_rate

  def set_vat_rate
    self.vat_rate = buyer.vat_rate
  end

  # TODO: - move to submodule of Month and add 'has_month :period' or
  # similar helper
  def period=(value)
    # TODO: duck type it
    if ::Month === value
      @period = value
    elsif Range === value
      @period = ::Month.new(value.begin.beginning_of_month)
    elsif String === value
      @period = ::Month.parse_month(value)
    else
      raise ArgumentError.new("Expected Month or Range instance, got #{value.class}")
    end

    self[:period] = @period.try!(:begin)
  end

  # REFACTOR: remove - use period.begin instead
  def period_start
    period.begin
  end

  # REFACTOR: remove - use period.end instead
  delegate :end, to: :period, prefix: true

  def vat_amount
    (BigDecimal((vat_rate || 0).to_s) / 100 *
     exact_cost_without_vat).to_has_money(currency)
  end

  def charge_cost_vat_amount
    vat_amount.round(CHARGE_PRECISION)
  end

  def exact_cost_without_vat
    line_items.sum(:cost).to_has_money(currency)
  end

  def charge_cost_without_vat
    exact_cost_without_vat.round(CHARGE_PRECISION)
  end

  def charge_cost_with_vat
    charge_cost_without_vat + charge_cost_vat_amount
  end

  def exact_cost_with_vat
    (charge_cost_without_vat + charge_cost_vat_amount).to_has_money(currency)
  end

  def charge_cost
    charge_cost_with_vat.to_has_money(currency)
  end

  def next_transition_from_state(state)
    state_transitions.find {|t| t.to == state.to_s }
  end

  # @deprecated
  def cost(vat_included: true, rounding: CHARGE_PRECISION)
    sum = vat_included ? exact_cost_with_vat : exact_cost_without_vat

    if rounding
      sum = sum.round(CHARGE_PRECISION)
    end

    sum.to_has_money(currency)
  end

  # REFACTOR: remove this method and replace it by open?
  def current?
    period.same_month?(Time.now.utc.to_date) && !buyer_account.try!(:destroyed?)
  end

  def editable?
    open? || finalized?
  end

  def check_editable_line_items
    raise InvalidInvoiceStateException, state unless editable?
  end

  def issue_and_pay_if_free!
    issue!
    pay! if self.cost == 0
  end

  # Enhances the AASM allowed_event? method so that it
  # can also govern other methods.
  #
  # REFACTOR: read more about loopback transitions in
  # http://www.pluginaweek.org/
  def transition_allowed?(event)
    allowed = case event
              when :charge
                 [ :pending, :failed, :unpaid ].include?(self.state.to_sym)
              when :generate_pdf
                true
              else
                state_events.include?(event)
              end
  end


  # REFACTOR: charging should not happen here
  # When charging is successful, the invoice is marked as paid (method
  # #pay! is called)
  #
  def charge!(automatic = true)
    ensure_payable_state!

    unless chargeable?
      logger.info "Not charging invoice ID #{self.id} (#{reason_cannot_charge})"
      cancel! unless positive?
      return
    end

    if buyer_account.charge!(cost, :invoice => self)
      provider.billing_strategy.try!(:info , "Charging invoice for #{buyer.name} for period #{period}", buyer)
      pay!
    else
      logger.info("Invoice(#{self.id}) was not charged")
      false
    end
  rescue Finance::Payment::CreditCardError, ActiveMerchant::ActiveMerchantError
    provider.billing_strategy.try!(:error, "Charging for invoice for #{buyer.name} error", buyer)
    logger.info("Error charging invoice #{self.id}")

    if automatic
      self.charging_retries_count += 1
      self.last_charging_retry = Time.now.utc.to_date

      # REFACTOR: Move the logic to InvoiceMessenger
      if charging_retries_count < MAX_CHARGE_RETRIES
        if unpaid?
          logger.info("Retrying #{self.id}, unpaid")
          save!
        else
          logger.info("Retrying #{self.id}, marking as unpaid")
          mark_as_unpaid!
        end

        InvoiceMessenger.unsuccessfully_charged_for_buyer(self).deliver

        # do not send email if provider's using new notification system
        unless provider_account.provider_can_use?(:new_notification_system)
          InvoiceMessenger.unsuccessfully_charged_for_provider(self).deliver
        end

        event = Invoices::UnsuccessfullyChargedInvoiceProviderEvent.create(self)
        Rails.application.config.event_store.publish_event(event)
      else
        logger.info("Retrying #{self.id} failed (too many retries)")
        fail!
        # TODO: Decouple the notification to observer and delete the IF
        InvoiceMessenger.unsuccessfully_charged_for_buyer_final(self).deliver

        # do not send email if provider's using new notification system
        unless provider_account.provider_can_use?(:new_notification_system)
          InvoiceMessenger.unsuccessfully_charged_for_provider_final(self).deliver
        end

        event = Invoices::UnsuccessfullyChargedInvoiceFinalProviderEvent.create(self)
        Rails.application.config.event_store.publish_event(event)
      end
    end
  end

  def ensure_payable_state!
    return if state_events.include?(:pay)

    logger.info("Invoice(#{self.id}) was not charged because the state events don't include :pay")
    raise InvalidInvoiceStateException.new("Invoice #{id} is not in chargeable state!")
  end

  delegate :positive?, :negative?, :zero?, to: :cost
  delegate :present?, :payment_gateway_configured?, to: :provider, prefix: true
  delegate :paying_monthly?, to: :buyer_account, prefix: true

  def not_paid?
    !paid?
  end

  CONDITIONS_TO_CHARGE = %i[not_paid provider_present provider_payment_gateway_configured positive buyer_account_paying_monthly].freeze

  def reason_cannot_charge
    reason = CONDITIONS_TO_CHARGE.find { |condition| !method("#{condition}?").call }
    I18n.t(reason, scope: %i[invoices reasons_cannot_charge]) if reason
  end

  def chargeable?
    !reason_cannot_charge
  end

  def latest_pending_payment_intent
    payment_intents.latest_pending.first
  end

  def self.opened_by_buyer(buyer)
    opened.by_provider(buyer.provider_account)
           .where(['invoices.buyer_account_id = ?', buyer.id ])
           .reorder('period DESC, created_at DESC').first
  end

  # TODO: are those needed without provider/buyer scope?
  # The month should be a YYYY-MM formated string.
  def self.find_by_month(month)
    by_month(month).first
  end

  # TODO: are those needed without provider/buyer scope?
  def self.find_by_month!(month)
    find_by_month(month) ||
      raise(ActiveRecord::RecordNotFound, "Couldn't find #{name} by month=#{month}")
  end

  # TODO: investigate this ... should not be happening on-demand
  #
  def self.find_by_provider_account!(provider_account)
    find_by_provider_account_id(provider_account.to_param)
  end

  # TODO: scheduled for removal - see bill_for method on contract
  def used?
    true
  end

  # TODO: Remove both lines from Invoice
  def mark_as_used
    # noop
  end

  def should_bill?
    buyer_account.billing_monthly?
  end

  def friendly_id_already_used?
    self.provider_account.buyer_invoices.by_number(friendly_id).without_ids(self).exists?
  end

  def counter
    provider_account.buyer_invoice_counters.find_or_create_by(invoice_prefix: id_prefix)
  end

  def id_prefix
    return if friendly_id.blank?
    friendly_id.sub(/(-[^-]+?)$/, '')
  end

  def id_sufix
    return if friendly_id.blank?
    friendly_id.sub(/(.+)-/, '')
  end

  after_commit :set_friendly_id, on: :create
  after_commit :update_counter, on: :update

  def set_friendly_id
    return unless persisted?
    self.friendly_id = InvoiceFriendlyIdService.call(self)
  end

  private :set_friendly_id

  def update_counter
    return unless previous_changes.key?(:friendly_id)
    counter.update_count(id_sufix.to_i)
  end

  def buyer_field_label(name)
    (buyer_account || provider_account.buyer_accounts.build).field_label(name)
  end

  # Returns years which have invoice
  def self.years
    self.connection.select_values(selecting { sift(:year, period).as('year') }.reorder('year desc').to_sql).map(&:to_i)
  end

  protected

  def notify_buyer_about_payment
    run_after_commit do
      InvoiceMessenger.successfully_charged(self).deliver
    end
  end
end
