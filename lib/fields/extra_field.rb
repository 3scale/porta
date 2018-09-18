class Fields::ExtraField < Fields::BaseField

  # this object is passed to form builder instead of owner of extra fields
  # it delegates errors to original object and responds to attr reader method
  class InputField < BasicObject

    def self.excludes
      instance_methods.map(&:to_s)
    end

    def initialize(name, object)
      @object = object
      @name = name.to_s
    end

    def method_missing(method, *args, &block)
      if method.to_s == @name
        __object_value__
      else
        @object.__send__(method, *args, &block)
      end
    end

    alias send method_missing
    alias public_send send

    private

    def __object_value__
      @object.extra_fields.try!(:[], @name)
    end
  end

  def name=(val)
    val ||= 'field_name_missing'
    @name = val
  end


  def input(builder)
    field = InputField.new(@name, builder.object)

    builder.fields_for :extra_fields, field do |form|
      form.input(@name, builder_options)
    end
  end
end
