# frozen_string_literal: true

module TestHelpers
  module Cinstance
    def create_pending_cinstance
      FactoryBot.create(:cinstance, plan: FactoryBot.create(:application_plan, approval_required: true))
    end
  end
end
