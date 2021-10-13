class FieldsDefinition < ApplicationRecord

  DEFAULT_LABELS = {
    "org_name" => "Organization/Group Name",
    "org_legaladdress" => "Legal Address"
  }.freeze


  @targets = []
  class << self
    attr_reader :targets
  end

  def self.push_target(klass)
    @targets << klass.to_s
  end

  serialize :choices, Array

  belongs_to :account, :inverse_of => :fields_definitions
  acts_as_list :scope => %i[account_id target], :column => :pos

  scope :by_provider,  ->(provider) { where(['account_id = ?', provider.id]) }
  scope :by_target, ->(class_name) { where(['target = ?', class_name])}
  scope :by_name, ->(name) { where(['name = ?', name])}
  scope :required, -> { where({ :required => true })}

  def self.editable_by(user)
    select{ |fd| fd.editable_by?(user) }
  end

  before_validation :set_required_if_required_field_on_target

  validates :label, :target, :name, presence: true, length: { maximum: 255 }
  validates :name, format: { :with =>/\A[A-Za-z][A-Za-z\d_-]*\z/, :message => "Name should start with letters, and can contain numbers, - and _" }
  validates :name, uniqueness: { :scope => [:account_id, :target] }
  validates :name, :exclusion => Fields::ExtraField::InputField.excludes
  validates :choices, :hint, length: { maximum: 65535 }

  validate :allowed_fields_definition_name, :check_base_validations, :read_only_billing_address, if: :target?
  validate :only_choices_for_text, if: %i[target? choices?]

  before_create :set_last_position_in_target_scope

  before_destroy :avoid_destroy_required_field_on_target

  default_scope { by_position }
  scope :by_position, -> { order(:pos) }

  attr_protected :account_id, :tenant_id
  attr_readonly :account_id, :tenant_id, :target, :name

  alias_attribute :position, :pos

  # This smells of :reek:NestedIterators: FieldsDefinition#self.create_defaults! contains iterators nested 2 deep
  def self.create_defaults!(account)
    targets.each do |target|
      klass = target.constantize
      klass.required_fields.each do |field|
        label = DEFAULT_LABELS[field] || field.humanize
        account.fields_definitions.create!({target: target, name: field, label: label, required: true})
      end
    end
  end

  def editable_by?(user)
    acc = user.try!(:account)
    # if self.account == acc
    if acc && !acc.buyer?
      true
    else
      not read_only? and not hidden?
    end
  end

  def targets
    self.class.targets
  end

  def target=(t)
    self[:target] = t if targets.include?(t)
  end

  def visible_for?(user)
    if self.account != user.account
      !self.hidden?
    else
      true
    end
  end

  def target_class
    return if target.nil?

    target.constantize
  end

  def required_field_on_target?
    target_class.required_fields.include?(name)
  end

  def choices_for_views=(values)
    values = values.to_s
    split_values = values.split(values.include?("\n") ? /\n/ : /\,/)
    self[:choices] = split_values.map(&:strip).presence
  end

  def choices_for_views
    views_choices = Array(self[:choices])
    join_by = views_choices.any? { |c| c.include?(',') } ? "\n" : ", "
    views_choices.join(join_by).presence
  end

  private

  def target?
    target.present?
  end

  def choices?
    choices.any?
  end

  def set_last_position_in_target_scope
    fields_for_target = self.account.fields_definitions.where(target: target)
    max_position = fields_for_target.maximum(:pos) || 0
    self.position = max_position + 1
  end

  def allowed_fields_definition_name
    return if target.nil? # the target presence validation already caught this

    forbidden = ( (target_class.new.attributes.keys| target_class.column_names) -
                  target_class.builtin_fields)
    if forbidden.include?(name)
      errors.add(:name, "Field name is not allowed")
    end
  end

  def check_base_validations
    if self.required? && (self.hidden? || self.read_only?)
      errors.add(:required,  "Fields cannot be required AND hidden/read_only")
    end
  end

  def only_choices_for_text
    return unless target_class.builtin_fields.include?(name) # It's allowed by 3scale and in DB

    column_name_attribute = target_class.columns_hash[name]
    return if %i[string text].include?(column_name_attribute&.type)

    # It's not a text attribute.
    errors.add(:choices,  "are not allowed for #{column_name_attribute&.type.presence || 'this type of'} fields")
  end

  def set_required_if_required_field_on_target
    return unless target?

    if required_field_on_target?
      self.required  = true
      self.hidden    = false
      self.read_only = false
    end

    true
  end

  def read_only_billing_address
    if target_class == Account && name == 'billing_address' && !self.read_only?
      errors.add(:read_only, "billing_address has to be read_only")
    end
  end

  def avoid_destroy_required_field_on_target
    throw :abort if required_field_on_target?
  end

end
