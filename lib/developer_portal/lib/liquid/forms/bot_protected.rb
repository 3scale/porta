# frozen_string_literal: true

module Liquid
  module Forms
    class BotProtected < Forms::Create
      include ThreeScale::BotProtection::Form

      def initialize(context, _object_name, html_attributes = {})
        # FIXME: object_name should be removed and the template password/new fixed. We're
        # accidentally passing a bracket '{'
        super(context, 'site_account', html_attributes)
      end

      def render(content)
        super(content + bot_protection_inputs)
      end

      delegate :input, :semantic_errors, to: :form_builder

      def site_account
        context.registers[:site_account]
      end

      protected

      def model
        @model ||= object.instance_variable_get(:@model)
      end

      def form_builder
        @form_builder ||= begin
          object_name = ActiveModel::Naming.param_key(model)
          Formtastic::FormBuilder.new(object_name, model, template, {})
        end
      end
    end
  end
end
