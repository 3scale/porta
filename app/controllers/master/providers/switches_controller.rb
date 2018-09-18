module Master
  module Providers
    class SwitchesController < Master::Providers::BaseController
      before_action :login_required
      before_action :authenticate_master!
      before_action :find_switch

      def update
        head(@switch.allow ? :found : :not_modified, location: :back)
      end

      def destroy
        head(@switch.deny ? :found : :not_modified, location: :back)
      end

      protected

      def back_url
        request.referer
      end

      def find_switch
        # the to_sym is technically insecure, BUT! it is used only in master authenticated session, so pretty safe
        @switch ||= @provider.settings.switches.fetch(params.require(:id).to_sym){ return head(:not_found) }
      end
    end
  end
end
