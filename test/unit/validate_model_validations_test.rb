require 'test_helper'

class ValidateModelValidationsTest < ActiveSupport::TestCase

  class CustomLengthValidator < ActiveModel::Validations::LengthValidator

    def validate(object)
      attributes.each do |attribute|

        errors        = []
        has_validator = false

        object.class.validators.each do |validator|

          next if Array(validator.try(:attributes)).exclude?(attribute.to_sym)

          if validator.is_a?(ActiveModel::Validations::LengthValidator)
            options.except(:allow_blank).each do |option, value|

              if validator.options[option].blank?
                errors.push("#{attribute} { #{option}: #{value} } validation is missing")
                next
              end

              if validator.options[option] != value
                errors.push("#{attribute} { #{option}: #{value} } validation has incorrect value")
              end
            end

            has_validator = errors.blank?
          end
        end

        unless has_validator
          error_message = "[#{object.class.name}] "

          if errors.present?
            error_message += "[incorrect validation] #{errors.join(', ')}"
          else
            message_options = options.map { |key, value| "#{key}: #{value}" }.join(', ')
            error_message   += "[missing validation] validates :#{attribute}, length: { #{message_options} }"
          end

          raise Minitest::Assertion, error_message
        end
      end
    end
  end

  def validate_model_validations(model)
    columns_to_validate = model.column_names.map(&:to_s)
    minitest_errors     = []

    columns_to_validate.each do |column|
      column_schema = model.columns.find { |c| c.name == column }

      next if column_schema.nil?
      next if [:string, :text].exclude?(column_schema.type)
      next if column_schema.respond_to?(:array) && column_schema.array

      next unless column_schema.limit

      begin
        CustomLengthValidator.new(maximum: column_schema.limit, allow_blank: true, attributes: [column]).validate(model.new)
      rescue Minitest::Assertion => error
        minitest_errors.push(error)
      end
    end

    raise(Minitest::Assertion, minitest_errors.join("\n")) if minitest_errors.present?
  end

  THIRD_PARTY_CLASSES = [ActiveRecord::SchemaMigration, ActsAsTaggableOn::Tagging,
    Audited::Adapters::ActiveRecord::Audit, RailsEventStoreActiveRecord::Event]

  Rails.application.eager_load!

  ActiveRecord::Base.subclasses.each do |model|

    define_method "test_#{model.name.downcase}" do

      raise Minitest::Skip, '[temp] will be fixed in #8139'

      if THIRD_PARTY_CLASSES.include?(model)
        raise Minitest::Skip, "[#{model.name}] is not editable, skipping test"
      end

      if model.parents.any? { |parent| parent.name.include?('Test') }
        raise Minitest::Skip, "[#{model.name}] is defined in test namespace"
      end

      validate_model_validations(model)
    end
  end
end
