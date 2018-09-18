module Liquid
  module Drops

    class Buyer < Drops::Base
      allowed_name :buyer

      # TODO: from quick search it looks like this is not used at all
      def initialize(buyer_account, service, options = {})
        @buyer = buyer_account
        @service = service
      end

      def bought_plan
        plan = @buyer.bought_cinstances.by_service(@service).first.plan
        Drops::Plan.new(plan)
      end

      def name
        @buyer.org_name
      end

    end
  end
end
