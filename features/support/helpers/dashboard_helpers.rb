# frozen_string_literal: true

module DashboardHelpers
  def stub_integration_errors_dashboard
    @provider.services.pluck(:id).each do |id|
      stub_core_integration_errors(service_id: id)
    end
  end
end

World(DashboardHelpers)
