module Liquid
  module Drops
    class Service < Drops::Model

      allowed_name :service

      def initialize(service, opts = {})
        super(service)

        @service = service
        @subscribed = opts[:subscribed] || false
      end

      hidden
      deprecated "Use **system_name** instead."
      def id
        # Expected to be deprecated soon
        # ThreeScale::Warnings.deprecated_method(:id)
        @service.id
      end

      desc "Returns the name of the service."
      def name
        @service.name
      end

      desc "Returns the system name of the service."
      example %{
        {% case service.system_name %}
        {% when 'api' %}
          API is our newest service!
        {% when 'old' %}
          Unfortunately we dont allow more signups to our old service.
        {% endcase %}
      }
      def system_name
        @service.system_name
      end

      desc "Returns the description of the service."
      def description
        @service.description
      end


      desc "Returns whether the service is subscribed to."
      deprecated 'use method **subscription** instead'
      example %{
        {% if service.subscribed? %}
           <p>You already subscribed to this service.</p>
        {% endif %}
      }
      def subscribed?
        @subscribed
      end


      desc %{
             Returns subscription (`ServiceContract` drop) of the currently
             logged in user if they are subscribed to this service, Nil otherwise.
            }
      example %{
        {% if service.subscription %}
           Your applications for service {{ service.name }} are:
           {% for app in service.subscription.applications %}
             {{ app.name }}<br/>
           {% endfor %}
        {% else %}
           <p>You are not subscribed to this.</p>
        {% endif %}
      }
      def subscription
        if account = ::User.current.try(:account)
          if contract = @service.service_contract_of(account)
            Drops::ServiceContract.new(contract)
          end
        end
      end

      # TODO: separate `can`
      def subscribable?
        !!@service.can_create_service_contract?
      end

      def subscribe_url
        cms_url_helpers.new_admin_service_contract_path(service_id: @service)
      end

      desc "Returns the **published** application plans of the service."
      example %{
        {% for service in model.services %}
          <h3>{{ service.name }} application plans:</h3>
          <dl>
          {% for application_plan in service.application_plans %}
            <dt>{{ application_plan.name }}</dt>
            <dd>{{ application_plan.system_name }}</dd>
          {% endfor %}
          </dl>
        {% endfor %}
      }
      def application_plans
        Drops::ApplicationPlan.wrap(@service.application_plans.published)
      end

      desc "Returns the *published* service plans of the service."
      example %{
        <p>We offer following service plans:</p>
        <dl>
        {% for service in model.services %}
          {% for service_plan in service.service_plans %}
            <dt>{{ service_plan.name }}</dt>
            <dd>{{ service_plan.system_name }}</dd>
          {% endfor %}
        {% endfor %}
        </dl>
      }
      def service_plans
        Drops::ServicePlan.wrap(@service.service_plans.published)
      end

      desc "Returns the application plans of the service."
      deprecated "Use **application_plans** and **service_plans** instead."
      def plans
        Drops::Plan.wrap(@service.visible_plans_for(current_account))
      end

      desc "Returns the visible features of the service."
      example %{
        {% if service.features.size > 0 %}
          <p>{{ service.name }} has following features:</p>
          <ul>
          {% for feature in service.features %}
            <li>{{ feature.name }}</li>
          {% endfor %}
          </ul>
        {% else %}
          <p>Unfortunately, {{ service.name }} currently has no features.</p>
        {% endif %}
      }
      def features
        Drops::Feature.wrap(@service.features.visible)
      end

      desc %{
       Depending on the authentication mode set, returns either 'ID',
       'API key' or 'Client ID' for OAuth authentication.
      }
      example %{
         {{ service.application_key_name }}
      }
      def apps_identifier
        case @service.backend_version
        when "2"
          "ID"
        when "oauth"
          "Client ID"
        else
          "API Key"
        end
      end

      def backend_version
        @service.backend_version
      end

      def referrer_filters_required?
        @service.referrer_filters_required?
      end

      # TODO: explain what means top_level metrics
      desc "Returns the metrics of the service."
      example %{
        <p>On {{ service.name }} we measure following metrics:</p>
        <ul>
        {% for metric in service.metrics %}
          <li>{{ metric.name }}</li>
        {% endfor %}
        </ul>
      }
      def metrics
        Drops::Metric.wrap(@service.metrics.top_level)
      end

      # TODO: remove this and remove all references, views, controllers
      hidden
      deprecated "Use **support_email** instead."
      def admin_support_email
        @service.support_email
      end

      desc "Support email of the service."
      def support_email
        @service.support_email
      end

      # TODO: remove this and all references, views
      hidden
      def infobar
        @service.infobar
      end

      private

      def current_account
        context.registers[:current_account]
      end
    end
  end
end
