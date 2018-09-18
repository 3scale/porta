# frozen_string_literal: true

module Logic
  module Signup
    module Provider
      def create_buyer_possible?
        account_plans.stock.present?
      end

      def signup_enabled?
        try(:settings).try!(:signups_enabled?) && (account_plans.published.present? || account_plans.default)
      end

      def enable_signup!
        settings.update_attribute(:signups_enabled, true)
        self
      end

      def disable_signup!
        settings.update_attribute(:signups_enabled, false)
        self
      end
    end
  end
end
