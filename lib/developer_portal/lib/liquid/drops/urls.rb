module Liquid
  module Drops

    # TODO: test these by building a view that will compare the
    # generated strings with actual *_paths method outputs.
    #
    class Urls < Drops::Base
      allowed_name :urls

      attr_reader :provider
      protected :provider

      def initialize(provider, request=nil)
        @provider = provider
        @request = request
        @request.extend(ThreeScale::DevDomain) if ThreeScale::DevDomain.enabled?
      end

      example %{
        <a href="{{ urls.signup }}">sign up here</a>
        <a href="{{ urls.service_subscription }}">subscribe to a service here</a>
      }

      def cas_login
        @strategy = Authentication::Strategy.build(provider)
        return "" unless @strategy.name == "cas"
        @strategy.login_url_with_service
      end

      def new_application
        ::Liquid::Drops::Url.new(new_admin_application_url)
      end

      desc "URL of a signup page. Accessible for everyone."
      example %{
        <a href="{{ urls.signup }}?{{ service_plan | param_filter }}&{{ app_plan | param_filter }}" >Signup Now!</a>
      }
      def signup
        ::Liquid::Drops::Url.new(signup_url)
      end

      desc "URL which all the search requests should be sent to."
      example %{
         <form action="{{ urls.search }}" method="get">
           <input name="q" type="text" title="Search the site" value=""/>
           <input type="submit" value="Search" name="commit">
         </form>
      }
      def search
        ::Liquid::Drops::Url.new(search_url)
      end

      def login
        ::Liquid::Drops::Url.new(login_url)
      end

      def logout
        ::Liquid::Drops::Url.new(logout_url)
      end

      def forgot_password
        ::Liquid::Drops::Url.new(new_admin_account_password_url)
      end

      desc "URL to the service subscription page. Only for logged in users."
      example %{
        <a href="{{ urls.service_subscription }}?{{ service_plan | param_filter }}" >
          Subscribe to service {{ service.name }}
        </a>
      }
      def service_subscription
        ::Liquid::Drops::Url.new(new_admin_service_contract_url)
      end

      desc "URL to a page that allows the developer to contact provider via the internal messaging system."
      deprecated "Please use `messages_new` instead."
      def compose_message
        ::Liquid::Drops::Url.new(new_admin_messages_outbox_url)
      end

      desc "URL to a page that allows the developer to contact provider via the internal messaging system."
      def messages_new
        ::Liquid::Drops::Url.new(admin_messages_new_url)
      end

      desc "URL to the list of messages sent by a developer."
      def messages_outbox
        ::Liquid::Drops::Url.new(admin_messages_outbox_index_url)
      end

      def messages_trash
        ::Liquid::Drops::Url.new(admin_messages_trash_index_url)
      end

      def empty_messages_trash
        ::Liquid::Drops::Url.new(empty_admin_messages_trash_index_path)
      end

      def credit_card_terms
        ::Liquid::Drops::Url.new(url_for(provider.settings.cc_terms_path))
      end

      def credit_card_privacy
        ::Liquid::Drops::Url.new(url_for(provider.settings.cc_privacy_path))
      end

      def credit_card_refunds
        ::Liquid::Drops::Url.new(url_for(provider.settings.cc_refunds_path))
      end

      desc "URL or Nil if user account management is disabled (check your [usage rules section][usage-rules])."
      def personal_details
        if provider.settings.useraccountarea_enabled?
          ::Liquid::Drops::Url.new(admin_account_personal_details_url, 'Personal Details', 'personal_details')
        end
      end

      desc "A page with API key(s) and other authentication information. Depends on the authentication strategy."
      def access_details
        ::Liquid::Drops::Url.new(admin_applications_access_details_url)
      end

      desc "Page to invite new users."
      def new_invitation
        ::Liquid::Drops::Url.new(new_admin_account_invitation_url)
      end

      desc "List of all the sent invitations."
      def invitations
        ::Liquid::Drops::Url.new(admin_account_invitations_url, 'Invitations', 'invitations')
      end

      # Dashboard menu
      def dashboard
        ::Liquid::Drops::Url.new(admin_dashboard_path, 'Overview', 'dashboard')
      end

      def applications
        ::Liquid::Drops::Url.new(admin_applications_path, 'Applications', 'applications')
      end

      def api_access_details
        ::Liquid::Drops::Url.new(admin_applications_access_details_path, 'API Access Details', 'applications')
      end

      def services
        ::Liquid::Drops::Url.new(admin_buyer_services_path, 'Services', 'services')
      end

      desc "URL to the list of received messages."
      def messages_inbox
        ::Liquid::Drops::Url.new(admin_messages_inbox_index_url, 'Messages', 'messages')
      end

      def stats
        ::Liquid::Drops::Url.new(buyer_stats_path, 'Stats', 'stats')
      end

      # Account & Credit card menu
      def account_overview
        ::Liquid::Drops::Url.new(admin_account_path, 'Overview', '')
      end

      def users
        ::Liquid::Drops::Url.new(admin_account_users_path, 'Users', 'users')
      end

      def account_plans
        ::Liquid::Drops::Url.new(admin_account_account_plans_path, 'Plans', 'plans')
      end

      def invoices
        ::Liquid::Drops::Url.new(admin_account_invoices_path, 'Invoices', 'invoices')
      end

      desc "A page to enter credit card details. Differs depending on the payment gateway of your choice."
      def payment_details
        type = provider.payment_gateway_type

        if [ "bogus" ,""].include?(type.to_s)
          nil
        else
          url = polymorphic_path([:admin, :account, type])
          ::Liquid::Drops::Url.new(url, 'Credit Card Details', 'payment_details')
        end
      end

      private

      attr_reader :request, :provider

      # needed by all the *_url helpers
      def default_url_options
        if request
          host = request.try(:real_host) || request.host
          { port: request.port, protocol: request.protocol, host: host }
        else
          { protocol: 'https', host: provider.domain }
        end
      end
    end
  end
end
