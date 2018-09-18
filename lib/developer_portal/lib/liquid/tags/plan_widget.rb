module Liquid
  module Tags
    class PlanWidget < Liquid::Tags::Base
      OPTIONS_SIGNATURE_REGEXP = /\A(?:wizard:\s*(true|false))?\s*\Z/

      # Regexp used for 4 cases:
      #
      # # Without comma separator between variable name and wizard
      # {% plan_widget app wizard: true %} # Without semicolon between name and params
      # {% plan_widget: app wizard: true %} # With semicolon between name and params
      #
      # # With comma separator between variable name and wizard
      # {% plan_widget app, wizard: true %} # Without semicolon between name and params
      # {% plan_widget: app, wizard: true %} # With semicolon between name and params
      OPTIONS_STRIPPING_REGEXP = /\A(?::\s*)?([^\s,]+)(?:[\s,]+|\Z)/

      desc "Includes a widget to review or change application plan"
      example <<-EXAMPLE
       {% if application.can_change_plan? %}
         <a href="#choose-plan-{{ application.id }}"
            id="choose-plan-{{application.id}}">
           Review/Change
         </a>
         {% plan_widget application, wizard: true %}
       {% endif %}
      EXAMPLE

      def initialize(tag_name, params, tokens)
        super
        parse_variables(params)
      end

      def render(context)
        if drop = context[@variable_name]
          contract = drop.try(:contract)
          render_erb context, 'applications/applications/plan_widget',
                     contract: contract, wizard: @wizard
        else
          "Application '#{@variable_name}' not defined for plan_widget"
        end
      end

      protected

      def parse_variables(params)
        options = params.sub(OPTIONS_STRIPPING_REGEXP, '')
        @variable_name = Regexp.last_match && Regexp.last_match[1]
        @wizard = OPTIONS_SIGNATURE_REGEXP =~ options && Regexp.last_match[1] == 'true'
      end
    end
  end
end
