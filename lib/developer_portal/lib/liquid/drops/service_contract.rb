module Liquid
  module Drops
    class ServiceContract < Drops::Contract

      allowed_names :subscribed_services, :subscription

      # The service parameter is used when you are creating a new
      # subscription and the model does not have plan yet however, you
      # still want to restrict the subscription to only one service.
      #
      def initialize(service_contract, service = nil)
        @service = service
        super(service_contract)
      end

      # needed for plan widget in admin/services/index.html.liquid
      def id
        @model.id
      end

      delegate :name, to: :find_service

      delegate :system_name, to: :find_service

      def change_plan_url
        admin_contract_service_plans_path(@model.id)
      end

      def service
        if s = find_service
          Drops::Service.new(s)
        end
      end

      def applications
        app_plans = @model.service.application_plans.pluck(:id)
        apps = @model.account.bought_cinstances.where("plan_id in (?)", app_plans).limit(50)

        Drops::Application.wrap(apps)
      end

      desc 'Exposes specific rights of the current user for that subscription.'
      example %{
        {% if subscription.can.change_plan? %}
          ...
        {% endif %}
      }
      def can
        @__can ||= Can.new(@contract)
      end

      private

      class Can < Liquid::Drops::Base
        def initialize(contract)
          super()
          @contract = contract
        end

        def change_plan?
          @contract.provider_account.settings.service_plans.visible?
        end
      end

      def find_service
        @service || @model.service
      end

    end
  end
end
