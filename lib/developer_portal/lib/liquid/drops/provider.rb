module Liquid
  module Drops
    class Provider < Drops::Base

      example %{
        <div>Domain {{ provider.domain }}</div>

        {% if provider.multiple_applications_allowed? %}
           <div>
             <p>Applications</p>
             <ul>
             {% for app in account.applications %}
               <li>{{ app.name }}</li>
             {% endfor %}
             </ul>
           </div>
        {% else %}
           <div>Application {{ account.applications.first.name }}</div>
        {% endif %}

        For general questions contact us at {{ provider.support_email }}.
        For invoice or payment related questions contact us at {{ provider.finance_support_email }}.
      }

      allowed_name :provider
      deprecated_name :user_account, :provider_account, :sender, :site_account, :account

      def initialize(model)
        @model = model
        super()
      end

      desc "Returns name of your organization. That can be changed via the [admin dashboard][provider-account-edit]."
      def name
        @model.name
      end

      desc "Can be composed by legal address, city and state."
      def full_address
        @model.full_address
      end

      desc "Returns the country."
      def country_name
        @model.country_name
      end

      desc "Returns the payment gateway associated with your organization."
      def payment_gateway
        @__payment_gateway ||= Drops::PaymentGateway.new @model
      end

      desc "Domain of your developer portal."
      def domain
        @model.domain
      end

      desc "Returns timezone that you use. Can be changed in your [administration dashboard][provider-account-edit]."
      def timezone
        Drops::TimeZone.new(@model.timezone)
      end

      hidden
      #TODO: provider only
      desc "Returns whether this provider account requires credit card from buyers."
      def requires_credit_card?
        @model.billing_strategy.try(:needs_credit_card?)
      end

      hidden
      # DEPRECATED 'Use contract.paid? instead'
      def upgraded?
        paid?
      end

      desc "Support email of the account."
      def support_email
        @model.support_email
      end

      desc "Finance support email of the account."
      def finance_support_email
        @model.finance_support_email
      end

      desc "Returns the telephone number of the account."
      def telephone_number
        @model.telephone_number
      end

      desc """*True* if developers can have more separate applications with
              their own keys, stats, etc. __Depends on your 3scale plan__.
           """
      example %{
        {% if provider.multiple_applications_allowed? %}
           <div>
             <p>Applications</p>
             <ul>
             {% for app in account.applications %}
               <li>{{ app.name }}</li>
             {% endfor %}
             </ul>
           </div>
        {% else %}
           <div>Application {{ account.applications.first.name }}</div>
        {% endif %}
      }
      def multiple_applications_allowed?
        @model.settings.multiple_applications.visible?
      end


      def logo_url
        if logo = @model.profile.logo
          logo.url(:large)
        end
      end

      desc """*True* if your 3scale plan allows you to manage multiple APIs
               as separate [services][support-terminology-service].
           """
      example %{
        {% if provider.multiple_services_allowed? %}
          {% for service in provider.services %}
             Service {{ service.name }} is available.
          {% endfor %}
        {% endif %}
      }
      def multiple_services_allowed?
        @model.multiservice? && @model.has_visible_services_with_plans?
      end

      def finance_allowed?
        @model.settings.finance.visible?
      end

      desc """*True* if the developer accounts can have multiple logins
              associated with them (__depends on your 3scale plan__)
              and its visibility has been turned on for your develoeper
              portal in the [settings][cms-feature-visibility]."""
      example %{
        {% if provider.multiple_users_allowed? %}
          <ul id="subsubmenu">
            <li>
               {{ 'Users' | link_to: urls.users }}
            </li>
            <li>
              {{ 'Sent invitations' | link_to: urls.invitations }}
            </li>
          </ul>
        {% endif %}
      }
      def multiple_users_allowed?
        @model.settings.multiple_users.visible?
      end

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
        Drops::AccountPlan.wrap(@model.account_plans.published)
      end

      desc "Returns all defined services."
      example %{
        <p>You can sign up to any of our services!</p>
        <ul>
        {% for service in provider.services %}
          <li>{{ service.name }} <a href="/signup/service/{{ service.system_name }}">Signup!</a></li>
        {% endfor %}
      }
      def services
        Drops::Service.wrap(@model.services)
      end

      desc "You can enable or disable signups in the [usage rules section][usage-rules] of your admin dashboard."
      def signups_enabled?
        @model.settings.signups_enabled?
      end

      desc "You can enable or disable account management in the [usage rules section][usage-rules]."
      def account_management_enabled?
        @model.settings.useraccountarea_enabled?
      end

      desc "Returns the logo URL."
      example %{
        <img src={{ provider.logo_url }}"/>
      }
      def logo_url
        if logo = @model.try(:profile).try(:logo)
          logo.url(:large)
        end
      end

      desc 'Returns API spec collection.'
      def api_specs
        Drops::Collection.for_drop(Drops::ApiSpec).new(@model.api_docs_services.accessible)
      end

      private

      def admin
        @model.admins.first
      end
    end
  end
end
