module Liquid
  module Drops
    # Since Liquidizer is wrapping ALL instance variables, it tries to
    # wrap some of them wrongly. To prevent it from wrapping @signup
    # in SignupsController, this drop has different name. Change it
    # when this issue is fixed.
    #
    class NewSignup < Drops::Base

      allowed_name :model

      def initialize(site_account, params = {}, current_account = nil)
        @params = params.dup
        @provider = site_account
        @current_account = current_account
        @wrapper = Liquid::Wrapper.new( current_account, @params)
      end

      # TODO: consider using plan.system_name or exposing id of plan
      desc "Returns all published account plans."
      example %{
        <p>We offer following account plans:</p>
        <ul>
        {% for plan in model.account_plans %}
          <li>{{ plan.name }} <input type="radio" name="plans[id]" value="{{ plan.id }}"/></li>
        {% endfor %}
        </ul>
      }
      def account_plans
        @wrapper.wrap_plans(@provider.account_plans.published)
      end

      desc "Returns all defined services."
      example %{
        <p>You can signup to any of our services!</p>
        <ul>
        {% for service in model.services %}
          <li>{{ service.name }} <a href="/signup/service/{{ service.system_name }}">Signup!</a></li>
        {% endfor %}
      }
      def services
        @provider.services.map { |s| @wrapper.wrap_service(s) }
      end

      desc "Returns all selected plans."
      example %{
        {% if model.selected_plans.size > 0 %}
          <p>You have selected following plans:</p>
          <ul>
          {% for plan in model.selected_plans %}
            <li>{{ plan.name }}</li>
          {% endfor %}
          </ul>
        {% else %}
          <p>You have no selected plans.</p>
        {% endif %}
      }
      def selected_plans
        @wrapper.wrap_plans(raw_selected_plans)
      end

      private

      def raw_selected_plans
        return [] unless ids = @params[:plans]
        @provider.provided_plans.published.where(id: ids)
      end

    end
  end
end
