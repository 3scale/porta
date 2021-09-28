# OMG!!!! Such bad citizen!!!
# https://github.com/westonganger/protected_attributes_continued/blob/master/lib/active_record/mass_assignment_security/relation.rb
# They just reopened Rails module instead of using their proper module ...
# Thus they totally short circuit all the other modules, not really good with integration with other gems like BabySqueel

module ProtectedAttributesHacks
  module QueryMethods
    def sanitize_forbidden_attributes(attributes)
      if model._uses_mass_assignment_security
        # We just permit everything
        super(attributes.respond_to?(:permit!) ? attributes.dup.permit! : attributes)
      else
        super
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::QueryMethods.module_eval do
    remove_method :sanitize_forbidden_attributes
  end

  ActiveRecord::Relation.class_eval do
    include ProtectedAttributesHacks::QueryMethods
  end
end
