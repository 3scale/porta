module Master
  module Providers
    class BaseController < Master::BaseController
      include AuthenticatedSystem

      protected

      before_action :find_provider

      def site_account
        Account.master
      end

      alias domain_account site_account

      def unauthenticated
        head(:forbidden)
      end

      def find_provider
        @provider = Provider.find(params[:provider_id])
      end
    end
  end
end
