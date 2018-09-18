module Liquid
  module Drops
    class Site < Drops::Base

      allowed_name :site

      drop_example "Using site drop in liquid.", %{
        <div>Organization name {{ site.company_name }}</div>
        <div>Domain (accessed through account) {{ site.account.domain }}</div>
        <div>API (accessed through service) {{ site.service.name }}</div>

        <div>
          <p>Plans</p>
          <ul>
          {% for plan in site.plans %}
            <li>{{ plan.name }}</li>
          {% endfor %}
          </ul>
        </div>

        {% if site.forum? %}
          <p>The forum is enabled.</p>
        {% endif %}

        <a href="{{ site.theme_css_link }}">link theme to css</a>
      }

      def initialize(account, service = account.first_service)
        @account = account
        @service = service
      end

      def account
        Liquid::Drops::Provider.new(@account)
      end

      def forum?
        @account.settings.forum_enabled?
      end

      def service
        @service
      end

      def plans
        service.published_plans
      end

      def company_name
        @account.org_name
      end

      def favicon
        ThreeScale::Warnings.deprecated_method!(:favicon)
        @account.settings.favicon unless account.settings.favicon.blank?
      end

      def google_tracker_code
        ThreeScale::Warnings.deprecated_method!(:google_tracker_code)
        @account.settings.tracker_code || nil
      end

      def theme_css_link
        "/css/theme_css.css"
      end

      def authentication_providers
        Drops::Collection
          .for_drop(Drops::AuthenticationProvider)
          .new(@account.authentication_providers.published)
      end
    end
  end
end
