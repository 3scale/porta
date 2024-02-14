module Liquid
  module Forms
    class Signup < Forms::BotProtected

      def html_class_name
        'account formtastic'
      end

      def object_param_name(model)
        case model
          # BEWARE - KEEP ::User HERE OR YOU WILL RELEASE RANDOM DRAGONS!
          #
          # Unless you explicitely specify the exact class here, autoload
          # will load either ::User or Liquid::Forms::User, depending on
          # the order of the loading and will or will not return the correct
          # prefix.
          #
          # https://github.com/3scale/system/issues/2483
          #
        when ::User then 'account[user]'
        else super
        end
      end

      def render(content)
        super(content + selected_plans)
      end

      def form_options
        super.merge(id: 'signup_form')
      end

      def path
        signup_path
      end

      def recaptcha_action
        DeveloperPortal::Engine.routes.recognize_path(path).fetch(:controller)
      end

      protected

      def selected_plans
        ids = @context.registers[:request].try(:params).try(:fetch, :plan_ids, [])

        if ids.is_a?(Array)
          ids.map do |plan|
            tag(:input, type: 'hidden', name: 'plan_ids[]', value: plan)
          end.join("\n").html_safe
        else
          ''
        end
      end
    end
  end
end
