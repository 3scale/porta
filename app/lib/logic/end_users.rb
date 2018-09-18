# frozen_string_literal: true

module Logic
  module EndUsers
    module Service
      def end_users_allowed?
        self.end_user_plans.present?
      end
    end

    module ApplicationContract
      delegate :end_users_allowed?, to: :service

      # TODO: should check it is possible before returning the flag
      #
      # def end_users_required?
      # end
    end
  end
end
