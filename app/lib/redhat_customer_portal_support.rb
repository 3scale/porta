# frozen_string_literal: true

module RedhatCustomerPortalSupport
  extend ActiveSupport::Concern

  RH_CUSTOMER_PORTAL_SYSTEM_NAME = 'redhat-customer-portal'

  included do
    after_commit :notify_entitlements
  end

  def redhat_customer_authentication_provider
    @redhat_customer_authentication_provider ||= AuthenticationProvider::RedhatCustomerPortal.build(account: self)
  end

  def redhat_account_recently_verified?
    extra_fields_change = saved_changes['extra_fields']

    return false unless extra_fields_change

    verified_by_was = extra_fields_change.first['red_hat_account_verified_by']
    verified_by = extra_fields_change.last['red_hat_account_verified_by']

    verified_by_was.blank? && verified_by.present?
  end

  def recently_suspended?
    saved_changes['state'] && suspended?
  end

  private

  def notify_entitlements
    return unless redhat_account_recently_verified? || recently_suspended?
    SupportEntitlementsService.notify_entitlements(self)
  end

  module ControllerMethods
    module AuthFlow
      extend ActiveSupport::Concern

      included do
        before_action :redhat_customer_portal_enabled
      end

      private

      def redhat_customer_portal_enabled
        return if ThreeScale.config.redhat_customer_portal.enabled
        render_error 'Authentication provider not enabled', status: :not_found
      end
    end

    module Banner
      extend ActiveSupport::Concern

      included do
        before_action :redhat_customer_portal_verification, if: :current_user
      end

      private

      def redhat_customer_portal_verification
        return unless ThreeScale.config.redhat_customer_portal.enabled
        @redhat_customer_portal_verification_presenter = RedhatCustomerOAuthFlowPresenter.new(current_account, request)
      end
    end
  end
end
