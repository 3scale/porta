class LineItem < ApplicationRecord
  DECIMALS = 4

  belongs_to :invoice, inverse_of: :line_items
  belongs_to :contract, polymorphic: true
  belongs_to :metric, inverse_of: :line_items

  audited associated_with: :invoice, allow_mass_assignment: true

  attr_accessible :name, :description, :cost, :finished_at, :quantity, :started_at

  validates :name, :description, :type, :contract_type, length: { maximum: 255 }
  validates :type, inclusion: {in: [LineItem::PlanCost, LineItem::VariableCost].flat_map { |klass| [klass, klass.to_s]}, allow_blank: true}

  default_scope -> { order(:created_at, :id) }

  delegate :plan_id, to: :contract, prefix: true, allow_nil: true

  scope :by_cinstance, -> (cinstance) do
    where(:cinstance_id => cinstance.to_param)
  end

  # REFACTOR: REMOVE!
  scope :by_period_including, lambda { |time|
      where(["#{table_name}.created_at <= ? AND #{table_name}.finished_at >= ?", time, time])
  }

  scope :oldest_first, -> { unscope(:order).order(:id) }

  delegate :currency, :buyer_account, :to => :invoice, :allow_nil => true

  def self.sum_by_invoice_state(state)
    includes(:invoice).references(:invoice).merge(Invoice.by_state(state.to_s)).sum(:cost)
  end

  def cost
    self[:cost].to_has_money(self.currency)
  end

  # We expect type to always be a String
  def type
    super.to_s
  end

  def cost=(value)
    self[:cost] = BigDecimal((value || 0).to_s).round(DECIMALS)
  end

  def custom?
    true
  end

  def plan_id
    super.presence || contract_plan_id
  end

  def to_xml(options = {})
    markup = Finance::Builder::XmlMarkup.new(options)
    markup.line_item!(self)
    markup.to_xml
  end
end
