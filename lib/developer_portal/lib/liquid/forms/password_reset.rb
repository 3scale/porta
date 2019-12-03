# frozen_string_literal: true

module Liquid
  module Forms
    class PasswordReset < Forms::Create

      def html_class_name
        'formtastic'
      end

      def path
        admin_account_password_path
      end

      def render(content)
        super(content + spam_protection)
      end

      delegate :input, :semantic_errors, to: :form_builder

      def template
        @context.registers[:view]
      end

      protected

      def model
        @model ||= object.instance_variable_get(:@model)
      end

      def spam_protection
        protector = model.spam_protection.form(self).to_s

        if protector.present?
          form_builder.inputs do
            template.concat(protector)
          end
        else
          ''
        end
      end

      def form_builder
        @form_builder ||= begin
                            object_name = ActiveModel::Naming.param_key(model)
                            Formtastic::SemanticFormBuilder.new(object_name, model, template, {})
                          end

      end
    end
  end
end
