# frozen_string_literal: true

module Fields
  module Provider
    def defined_fields_names_for(klass)
      fields_definitions.by_target(klass.name.underscore).map { |fd| fd.name.to_s }
    end

    def defined_builtin_fields_names_for(klass)
      defined_fields_names_for(klass) & klass.builtin_fields
    end

    def defined_extra_fields_names_for(klass)
      defined_fields_names_for(klass) - klass.builtin_fields
    end
  end
end
