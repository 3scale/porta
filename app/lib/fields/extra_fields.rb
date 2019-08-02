#this is tested in unit/account_test and in cucumbers
module Fields::ExtraFields
  extend ActiveSupport::Concern

  included do
    serialize :extra_fields, Hash
    validate  :extra_fields_valid?, :if => :validate_fields?
  end

  def extra_fields_valid?
    defined_fields.select(&:required).map(&:name).each do |field_name|
      if extra_field?(field_name) && (extra_fields.blank? ||
                                      extra_fields[field_name].blank?)
        errors.add(field_name, :blank)
      end
    end
  end

  def read_attribute_for_validation(name)
    if fields_definitions_source_root && extra_field?(name)
      extra_fields.try!(:[], name.to_s)
    else
      super
    end
  rescue LoadError => e
    case e.message
    when /You may need to install the aws-sdk gem/
      nil
    else
      raise
    end
  end

  def extra_fields
    super&.transform_values!(&method(:encode_extra_field))
  end

  # this methods does:
  # * only allows setting key value pairs in fields_definitions
  # * it avoids erasing keys (paranoid), to remove them use the [] notation, e.g.
  #   object[:extra_fields] = { :hash_without_existing_key => "value" }
  ## WARNING!!!! using the [] notation is not recommended, since you BYPASS this
  #              method and its checks
  def extra_fields=(new_extra_fields)
    self[:extra_fields] ||= {}

    new_extra_fields.each_pair do |field, value|
      if extra_field?(field)
        self.extra_fields[field] = encode_extra_field(value)
      end
    end
  end

  def extra_fields_to_xml(xml)
    xml.extra_fields do
      if extra_fields.present?
        extra_fields.each_pair do |field, value|
          if extra_field?(field) && value.present?
            if value.respond_to?(:each)
              value.each { |v| xml.tag!(field, v.strip) }
            else
              xml.tag!(field, value.strip)
            end
          end
        end
      end
    end
  end

  def update_with_flattened_attributes(flattened_attrs, options = {})
    assign_unflattened_attributes(flattened_attrs, options)
    save
  end

  def assign_unflattened_attributes(attributes, options = {})
    assign_attributes(nest_extra_fields(attributes), options)
  end

  def unflattened_attributes=(flattened_attrs)
    self.attributes = nest_extra_fields(flattened_attrs)
  end

  protected

  def encode_string_extra_field(value)
    # check if the string would be valid in our default encoding
    internal_encoding = Encoding.default_internal

    case value.encoding
    when internal_encoding
      value
    else
      encoded = value.dup.force_encoding(internal_encoding)
      encoded.valid_encoding? ? value.force_encoding(internal_encoding) : value
    end
  end

  def encode_extra_field(value)
    case value
    when String
      encode_string_extra_field(value)
    else
      value
    end
  end

  def nest_extra_fields(flattened_attrs)
    attrs = { }
    flattened_attrs.each_pair do |key, value|
      # we don't mind too much about this loose condition, that leads to push into
      # attrs[:extra_fields] many undesired things, since extra_fields= method will take
      # care of not allowing those to get in into the db
      if extra_fields_attribute?(key) || special_field?(key)
        attrs[key] = value
      else
        attrs[:extra_fields] ||= { }
        attrs[:extra_fields][key] = encode_extra_field(value)
      end
    end

    attrs
  end

  def extra_fields_attribute?(key)
    respond_to?("#{key}=") &&
        !(self.class.reflect_on_aggregation(key.to_sym) || self.class.reflect_on_association(key.to_sym))
  end
end
