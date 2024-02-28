# frozen_string_literal: true

class Fields::BuiltinField < Fields::BaseField

  ALLOWED_ASSOCIATIONS = %w[country].freeze

  def name=(val)
    @name = convert_name(val)
  end

  def input(builder, options = builder_options)
    # this is EXTREMELY dangerous
    # formtastic is getting reflection of association to get countries list
    # BUT it needs symbol, and when we give it a symbol, they can get any association of object,
    # so that's why it limits converting to symbol to just some attributes
    builder.input(@name.to_sym, options).html_safe
  end

  def convert_name(name)
    raise 'Missing name of a builtin field' unless name

    if ALLOWED_ASSOCIATIONS.include?(name)
      name.to_sym
    else
      name
    end
  end

end
