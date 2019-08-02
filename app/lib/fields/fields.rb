#this is tested in unit/account_test
module Fields::Fields
  extend ActiveSupport::Concern

  included do
    validate  :optional_fields_valid?, :if => :validate_fields?

    # Used to manualy set source in special cases
    attr_writer :fields_definitions_source

    @optional_fields = []
    @required_fields = []
    @internal_fields = []

    after_save :clear_fields_cache

    include Fields::ExtraFields
    prepend Fields::Fields::ActiverecordOverrides

    FieldsDefinition.push_target self
  end

  class NoFieldDefinitionsSourceObjectDefined < StandardError; end
  class NoFieldsDefinitionsSource < StandardError
    include Bugsnag::MetaData

    def initialize(object)
      self.bugsnag_meta_data = {
        object: object.as_json(root: false),
        source: object.class.try(:fields_source_object)
      }
    end
  end

  module ClassMethods
    # sets the model's required db-fields, it accepts params in several ways
    # required_fields_are :org_name, :org_legaladdress
    # required_fields_are %w{org_name org_legaladdress}
    def required_fields_are(*fields)
      @required_fields = fields.flatten.map(&:to_s)
    end

    # sets the model's optional db-fields, it accepts params in several ways
    # optional_fields_are :org_name, :org_legaladdress
    # optional_fields_are %w{org_name org_legaladdress}
    def optional_fields_are(*fields)
      @optional_fields = fields.flatten.map(&:to_s)
    end

    # sets the model's internal db-fields, it accepts params in several ways
    # These fields won't be editable by providers
    # internal_fields_are :org_name, :org_legaladdress
    # internal_fields_are %w{org_name org_legaladdress}
    def internal_fields_are(*fields)
      @internal_fields = fields.flatten.map(&:to_s)
    end


    def set_fields_source(method)
      @fields_source_object = method
    end
    alias set_fields_account_source set_fields_source

    def required_fields
      @required_fields
    end

    def optional_fields
      @optional_fields
    end

    def internal_fields
      @internal_fields
    end

    def fields_source_object
      @fields_source_object
    end

    def builtin_fields
      required_fields | optional_fields | internal_fields
    end

    def has_fields?
      true
    end

    # these fields are here to be able to recognize fields that are not in the
    # db but still can be updated and such. This is a need given the flatten
    # params on user-management-api, if that gets removed this won't be needed
    # e.g. password and password_confirmation in User
    def special_fields
      []
    end

  end # ClassMethods

  module ActiverecordOverrides
    ## fields definitions
    #

    # Fields definitions source has to be set before everything else
    # because fields needs source to validate attributes and handle dynamic ones when assigning
    def initialize(attributes = nil, *args)
      @fields_definitions_source = attributes.try!(:delete, :fields_definitions_source)

      super
    end

    # This overrides Rails method
    # it takes out all extra fields and assigns them separately
    # otherwise it raises exception on unknown (extra) fields
    # check http://api.rubyonrails.org/classes/ActiveRecord/AttributeAssignment.html#method-i-assign_attributes

    def assign_attributes(extra_attributes, options = {})
      # dup the fields because we are mutating them (params hash)
      attributes = extra_attributes.present? ? extra_attributes.dup : {}

      # when creating first provider there is no fields definitions source
      # maybe because of factories, maybe because of sun eruptions
      if fields_definitions_source_root
        extra_field_names = defined_extra_fields.map(&:name)
        new_attributes = attributes.slice!(*extra_field_names)
        self.extra_fields = attributes
      else
        new_attributes = attributes
      end

      super(new_attributes, options)
    end

    alias attributes= assign_attributes

    def reload(*)
      super
    ensure
      @fields_validations = nil
      @defined_fields_hash = nil
      @defined_fields = nil
      @fields_definitions_source = nil
    end
  end

  def required_fields
    self.class.required_fields
  end

  def optional_fields
    self.class.optional_fields
  end

  def builtin_fields
    self.class.builtin_fields
  end

  def internal_fields
    self.class.internal_fields
  end

  def special_fields
    self.class.special_fields
  end


  # TODO: implementation of field_definitions_object, fields_definitions_source_root_object, validate_fields?
  # is 3scale specific and should be extracted to separate module
  # and here should be just non implemented methods

  def fields_definitions_object
    raise NoFieldDefinitionsSourceObjectDefined unless self.class.fields_source_object

    source = self.class.fields_source_object

    object = if source == :self
      self
             else
      send(source)
             end

    object
  end

  # This methods is 3scale specific and overrides generic one
  # Traverses fields definitions source  to find proper account for fields definitions
  #
  # buyers take fields definitions from provider
  # providers get their fields_definitions from master
  # master always takes them from itself
  #
  def fields_definitions_source_root(source = fields_definitions_source)
    account = source

    return unless account

    # traverse accounts tree to find first saved provider or master
    begin
      next if account.new_record?

      valid = if source.buyer?
                account.provider?
              elsif source.provider?
                account.master?
              else
                account.master? or account.provider?
              end

       return account if valid
    end while account = account.try!(:provider_account)
  end

  def fields_definitions_source_root!
    fields_definitions_source_root(fields_definitions_source!) or raise NoFieldsDefinitionsSource, self
  end

  # This methods is 3scale specific and overrides generic one
  # fields should be validated if account is buyer
  #
  def validate_fields?
    (fields_definitions_object || fields_definitions_set_source).try!(:buyer?) and fields_validations?
  end

  # Returns previously set source via instance variable or tries to find by method set in model
  # the order is intentional - we dont want to call association methods
  # because they get cached before object has all attributes
  #
  # but when fields source is self, we can use it safely
  def fields_definitions_source
    if self.class.fields_source_object == :self
      fields_definitions_object
    else
      fields_definitions_set_source or fields_definitions_object
    end
  end

  def fields_definitions_source!
    fields_definitions_source or raise NoFieldsDefinitionsSource, self
  end

  # Returns set fields definitions source stored in instance variablr
  def fields_definitions_set_source
    @fields_definitions_source
  end

  def defined_fields
    @defined_fields ||= fields_definitions_source_root!.fields_definitions
      .by_target(self.class.to_s.underscore)
  end

  def visible_defined_fields_for(user)
    defined_fields.select { |field| field.visible_for?(user) }
  end

  def editable_defined_fields_for(user)
    defined_fields.select { |field| field.editable_by?(user) }
  end

  def defined_builtin_fields
    defined_fields.reject { |f| extra_field?(f.name) }
  end

  def defined_extra_fields
    defined_fields - defined_builtin_fields
  end

  def defined_fields_hash
    @defined_fields_hash ||= Hash[defined_fields.map{ |f| [f.name.to_sym, f]}]
  end

  def clear_fields_cache
    @defined_fields_hash = nil
  end

  ## validations

  #this makes optional_fields and extra_fields validations be active
  def validate_fields!
    @fields_validations = true
  end

  def fields_validations?
    !!@fields_validations
  end

  def optional_fields_valid?
    optional_fields.each do |field_name|
      field = field(field_name)
      next unless field.try!(:required?)

      if field_value(field.name).blank?
        errors.add(field_name, "can't be blank")
      elsif field.choices.present? &&
          field.choices.exclude?(field_value(field.name))
        errors.add(field_name, "illegal value")
      end

    end
  end

  ## fields accessing methods

  def builtin_field?(name)
    field(name) && builtin_fields.include?(name.to_s)
  end

  def extra_field?(name)
    field(name) && builtin_fields.exclude?(name.to_s) && internal_fields.exclude?(name.to_s)
  end

  def internal_field?(name)
    field(name) && internal_fields.include?(name.to_s)
  end

  def special_field?(key)
    special_fields.include?(key.to_sym)
  end

  def field(name)
    defined_fields_hash[name.to_sym]
  end

  def field_label(name)
    field(name).try(:label) || self.class.human_attribute_name(name)
  end

  def field_value(name)
    if extra_field?(name)
      self.extra_fields && self.extra_fields[name]
    elsif respond_to?(name)
      value = self.public_send(name)

      if value.is_a? ActiveRecord::Base
        value.name # this should check for multiple methods like label, etc.
        # or define some to_field_value method in each model
      else
        value
      end
    end
  end

  def fields_to_xml(xml)
    defined_builtin_fields.each do |field|
      if field_value(field.name).present?
        value = field_value(field.name)

        if value.respond_to?(:to_xml)
          value.to_xml(builder: xml, root: field.name)
        else
          xml.__send__(:method_missing, field.name, value.to_s.strip)
        end
      end
    end
  end
end
