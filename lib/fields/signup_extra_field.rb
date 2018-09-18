module Fields
  class SignupExtraField < ExtraField

    def builder_options
      options = super
      options[:as] = :hidden if hidden
      options
    end
  end
end
