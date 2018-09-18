module Liquid
  module Drops
    class ServicePlan < Drops::Plan
      allowed_name :service_plan

      example "Using service plan drop in liquid.", %{
        <p class="notice">The examples for plan drop apply here</p>
        <div>Service of this plan {{ plan.service.name }}</div>
      }

      def service
        Drops::Service.new(@plan.issuer)
      end
    end
  end
end
