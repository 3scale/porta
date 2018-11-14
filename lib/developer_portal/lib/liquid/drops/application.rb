module Liquid
  module Drops
    class Application < Drops::Contract
      drop_example "Using application drop in liquid.", %{
        <h1>Application {{ application.name }} (<span title="Application ID">{{ application.application_id }}</span>)</h1>
        <p>{{ application.description }}</p>
      }

      allowed_names :application, :applications
      deprecated_names :cinstance, :cinstances

      desc "Returns the id of the application."
      def id
        @contract.id
      end

      # Filter might be better, as in Shopify: http://cheat.markdunkley.com/
      desc "Returns the admin_url of the application."
      def admin_url
        Rails.application.routes.url_helpers.admin_service_application_url(@contract.service, @contract, host: @contract.provider_account.self_domain)
      end

      def path
        ::Liquid::Drops::Url.new(admin_application_path(@contract))
      end

      desc "Returns the name of the application."
      def name
        @contract.name
      end

      desc "Returns a plan drop with the plan of the application."
      def plan
        Drops::ApplicationPlan.new(@contract.plan)
      end

      def can
        @__can ||= Can.new @contract
      end

      def oauth
        @__oauth ||= Oauth.new @contract
      end

      desc "Returns 'true' if changing the application is allowed either directly or by request."
      # TODO: deprecated 'use plan.can.be_updated?' or similar
      def can_change_plan?
        @contract.can_change_plan?
      end

      desc "Returns 'true' if application state is pending."
      def pending?
        @contract.pending?
      end

      def buyer_alerts_enabled?
        @contract.buyer_alerts_enabled?
      end

      desc 'Returns a list of not-deleted alerts for this application'
      def alerts
        @alerts ||= begin
          collection = @contract.buyer_account.alerts.not_deleted.by_application(@contract).sorted
          Liquid::Drops::Collection.for_drop(Liquid::Drops::Alert).new(collection)
        end
      end

      desc "Returns the description of the application."
      def description
        @contract.description
      end

      desc "Returns the redirect URL for the OAuth request of the application."
      def redirect_url
        @contract.redirect_url
      end

      desc "Returns the amount of referrer filters allowed for this application."
      def filters_limit
        @contract.filters_limit
      end

      desc "Returns the amount of application keys allowed for this application."
      def keys_limit
        @contract.keys_limit
      end

      desc "Returns the referrer filters associated with this application."
      def referrer_filters
        Drops::Collection.for_drop(Liquid::Drops::ReferrerFilter).new(@contract.referrer_filters.reject(&:new_record?))
      end

      # TODO: this is available only in email templates sent after rejecting application
      desc "Returns the reason for rejecting an application."
      def rejection_reason
        @contract.rejection_reason
      end

      desc "Returns the user_key of application."
      def user_key
        # TODO: this might check for right backend version
        @contract.user_key
      end

      desc "Returns the application_id of an application."
      def application_id
        @contract.application_id unless @contract.service.backend_version.v1?
      end

      desc "Returns the application id or the user key."
      def key
        if @contract.service.backend_version.app_keys_allowed?
          @contract.application_id
        else
          @contract.user_key
        end
      end

      desc "Returns URL of the built-in detail view for this application."
      def url
        ::Liquid::Drops::Url.new(admin_application_path(@contract))
      end

      desc "Returns URL of the built-in edit view for this application."
      def edit_url
        ::Liquid::Drops::Url.new(edit_admin_application_path(@contract))
      end

      def update_user_key_url
        ::Liquid::Drops::Url.new(admin_application_user_key_path(@contract))
      end

      hidden
      def log_requests_url; end

      def alerts_url
        ::Liquid::Drops::Url.new(admin_application_alerts_path(@contract))
      end

      def purge_alerts_url
        ::Liquid::Drops::Url.new(purge_admin_application_alerts_path(@contract))
      end

      def mark_alerts_as_read_url
        ::Liquid::Drops::Url.new(all_read_admin_application_alerts_path(@contract))
      end

      def application_keys_url
        ::Liquid::Drops::Url.new(admin_application_keys_path(@contract))
      end

      desc "Service to which the application belongs to."
      def service
        Drops::Service.new(@contract.service)
      end

      desc "Returns the keys of an application."
      example %{
        {% case application.keys.size %}
        {% when 0 %}
          Generate your application key.
        {% when 1 %}
          <h3>Application key for {{ application.name }} {{ application.application_id }}</h3>
          <p>Key is: {{ application.keys.first }}</p>
        {% else %}
          <h3>Application keys for {{ application.name }} {{ application.application_id }}</h3>
          <ul>
            {% for key in application.keys %}
              <li>{{ key }}</li>
            {% endfor %}
          </ul>
        {% endcase %}
      }
      def keys
        # TODO: this might check for right backend version
        @contract.keys
      end

      # Authentication modes
      def oauth_mode?
        @contract.backend_version.oauth?
      end

      def user_key_mode?
        @contract.backend_version.v1?
      end

      def app_id_mode?
        @contract.backend_version.v2?
      end

      def change_plan_url
        admin_contract_application_plans_path(@model.id)
      end

      hidden
      def log_requests?; end

      def change_plan_url
        admin_service_plans_widget_path(@contract.service)
      end

      def application_keys
        Drops::Collection.for_drop(Liquid::Drops::ApplicationKey).new(@contract.application_keys)
      end

      desc "Returns non-hidden extra fields with values for this application."
      example "Print label and value of an existing extra field.", %{
        {{ application.extra_fields.oauth_token.label }}: {{ application.extra_fields.oauth_token.value }}
      }
      example "Print all extra fields.", %{
        {% for field in application.extra_fields %}
          {{ field.label }}: {{ field.value }}
        {% endfor %}
      }
      def extra_fields
        Drops::Fields.extra_fields(@contract)
      end

      desc "Returns all built-in and extra fields with values for this application."
      example "Print label and value of an existing field.", %{
        {{ application.fields.country.label }}: {{ application.fields.country.value }}
      }
      example "Print all fields.", %{
        {% for field in application.fields %}
          {{ field.label }}: {{ field.value }}
        {% endfor %}
      }
      def fields
        Drops::Fields.fields(@contract)
      end

      desc "Returns only built-in fields of the application."
      def builtin_fields
        Drops::Fields.builtin_fields(@contract)
      end

      private

      class Can < Liquid::Drops::Base
        def initialize(app)
          @application = app
          @ability = ::Ability.new(::User.current)
        end

        def be_updated?
          @ability.can?(:update, @application)
        end

        def be_destroyed?
          @ability.can?(:destroy, @application)
        end

        def add_referrer_filters?
          @application.referrer_filters.can_add?
        end

        def add_application_keys?
          @application.application_keys.can_add?
        end

        def regenerate_user_key?
          @ability.can?(:regenerate_user_key, @application)
        end

        def regenerate_oauth_secret?
          @application.service.buyer_key_regenerate_enabled
        end

        def manage_keys?
          @ability.can?(:manage_keys, @application)
        end

        def delete_key?
          @application.can_delete_key?
        end
      end

      class Oauth < Liquid::Drops::Base

        def initialize(app)
          @application = app
        end

        def create_secret_url
          admin_application_keys_path @application
        end

        def regenerate_secret_url
          cms_url_helpers.regenerate_admin_application_key_path(application_id: @application.id,
                                                                id: @application.keys.first)
        end
      end

      alias cinstance contract

    end
  end
end
