module Events
  class Event < OpenStruct
    # Ruby 1.8 thing
    undef_method :type rescue NameError

    def object
      @object ||= OpenStruct.new(super)
    end
  end
end


