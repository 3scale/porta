class Alert < ApplicationRecord
  include ThreeScale::Search::Scopes

  self.allowed_sort_columns = %w{ timestamp accounts.org_name state level utilization }
  self.sort_columns_joins = {'accounts.org_name' => :buyer_account }
  self.default_sort_column = :timestamp
  self.default_sort_direction = :desc
  self.allowed_search_scopes = %w[cinstance_id account_id timestamp level]

  ALERT_LEVELS = [ 50, 80, 90, 100, 120, 150, 200, 300 ]
  VIOLATION_LEVEL = 100

  belongs_to :cinstance
  belongs_to :account

  has_one :user_account, through: :cinstance

  attr_protected :account_id, :cinstance_id, :tenant_id

  validates :account, :timestamp, :state, presence: true
  validates :utilization, :level, :alert_id, :cinstance, presence: true
  validates :alert_id, uniqueness: { :scope => :account_id }
  validates :level, inclusion: { :in => ALERT_LEVELS }
  validates :level, numericality: { :only_integer => true }
  validates :utilization, numericality: true
  validates :state, length: { maximum: 255 }
  validates :message, length: { maximum: 65535 }

  before_create :set_service_id

  scope :violations, -> { where.has { level >=  VIOLATION_LEVEL }  }
  scope :alerts, -> { where.has { level < VIOLATION_LEVEL } }

  scope :by_level, ->(value) { where.has { level >= value } }
  scope :by_timestamp, ->(from, till) { where{ timestamp.in(from..till) } }
  scope :by_cinstance_id, -> (cinstance_id) { where(cinstance_id: cinstance_id) }
  scope :by_account_id, -> (*account_id) do
    joins(:cinstance)
    .references(:cinstance)
    .merge(Cinstance.where(user_account_id: account_id.flatten))
  end


  state_machine :initial => :unread do
    state :unread

    state :read
    state :deleted

    event :read do
      transition :unread => :read
    end

    event :delete do
      transition [:unread, :read] => :deleted
    end
  end

  state_machine.states.keys.each do |value|
    scope value, -> { where(:state => value.to_s) }
    scope "not_#{value}", -> { where{ state.not_eq value.to_s }}
  end

  scope :sorted, -> { reorder(timestamp: :desc) }
  scope :latest, -> { sorted.limit(5) }

  def self.by_service(service)
    scope = includes(:cinstance)

    if service == :all || service.blank?
      scope
    else
      scope.where(service_id: service)
    end
  end

  scope :by_application, lambda { |cinstance|
    return all if cinstance == :all || cinstance.nil?

    where(:cinstance_id => cinstance.id)
  }

  scope :with_associations, -> {  includes(cinstance: :user_account)  }

  def kind
    if level < 100
      :alert
    elsif level >= 100
      :violation
    end
  end

  def metric
    cinstance.metrics.find_by(system_name: system_name)
  end

  def friendly_name
    metric.friendly_name unless metric.nil?
  end

  def system_name
    if message && message.include?(' per ')
      msg = message.split(' per ')
      msg[0]
    end
  end

  def friendly_message
    if message && message.include?(' per ')
      msg = message.split(' per ')
      "#{friendly_name} per #{msg[1]}"
    else
      message
    end
  end

  protected

  def set_service_id
    self.service_id ||= cinstance.try(:service_id)
  end
end
