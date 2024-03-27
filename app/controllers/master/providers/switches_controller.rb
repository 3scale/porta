module Master
  module Providers
    class SwitchesController < Master::Providers::BaseController
      before_action :login_required
      before_action :authenticate_master!
      before_action :find_switch

      def update
        status = @switch.allow ? :found : :not_modified
        # Switch to `redirect_back_or_to` in Rails 7
        redirect_back(fallback_location: back_url, status: status)
      end

      def destroy
        status = @switch.deny ? :found : :not_modified
        # Switch to `redirect_back_or_to` in Rails 7
        redirect_back(fallback_location: back_url, status: status)
      end

      protected

      def back_url
        admin_buyers_account_path(@provider)
      end

      def find_switch
        # the to_sym is technically insecure, BUT! it is used only in master authenticated session, so pretty safe
        @switch ||= @provider.settings.switches.fetch(params.require(:id).to_sym){ return head(:not_found) } end
    end
  end
end
