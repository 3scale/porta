# frozen_string_literal: true

module Logic
  module ProviderConstraints
    def user_count
      users.but_impersonation_admin.count
    end

    def service_count
      services.count
    end
  end
end
