# frozen_string_literal: true

require 'test_helper'

module Abilities
  class CmsTest < ActiveSupport::TestCase
    #TODO: update/finish this? they can be a bit undry/unneeded with features/authorization/*.feature
    setup do
      @provider = FactoryBot.create(:provider_account)
    end

    test "enterprise mode provider admin should manage the portal" do
      ability = Ability.new(@provider.admins.first)
      assert ability.can?(:manage, :portal)
    end
  end
end
