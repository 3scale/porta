# frozen_string_literal: true

require 'test_helper'

module Abilities
  class MultipleApplicationsTest < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:provider_account)
      @admin = @provider.admins.first
      @member = FactoryBot.create(:member, account: @provider)
    end

    class SwitchDeniedTest < MultipleApplicationsTest
      def setup
        super
        assert @provider.settings.multiple_applications.denied?
      end

      test "should admin cannot manage multiple apps" do
        admin_ability = Ability.new(@admin)

        assert_can    admin_ability, :admin,  :multiple_applications
        assert_cannot admin_ability, :see,    :multiple_applications
        assert_cannot admin_ability, :manage, :multiple_applications
      end

      test "should member cannot manage multiple apps" do
        member_ability = Ability.new(@member)

        assert_cannot member_ability, :see,    :multiple_applications
        assert_cannot member_ability, :admin,  :multiple_applications
        assert_cannot member_ability, :manage, :multiple_applications
      end
    end

    class SwitchAllowedTest < MultipleApplicationsTest
      def setup
        super
        @provider.settings.allow_multiple_applications!
        assert @provider.settings.multiple_applications.allowed?
      end

      test "should admin can manage multiple apps" do
        admin_ability = Ability.new(@admin)

        assert_can admin_ability, :see,    :multiple_applications
        assert_can admin_ability, :admin,  :multiple_applications
        assert_can admin_ability, :manage, :multiple_applications
      end

      test "should member cannot manage multiple apps" do
        member_ability = Ability.new(@member)

        assert_can    member_ability, :see,    :multiple_applications
        assert_cannot member_ability, :admin,  :multiple_applications
        assert_cannot member_ability, :manage, :multiple_applications
      end

      test "should member with partners group can manage multiple apps" do
        member = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
        partners_ability = Ability.new(member)

        assert_can partners_ability, :see,    :multiple_applications
        assert_can partners_ability, :admin,  :multiple_applications
        assert_can partners_ability, :manage, :multiple_applications
      end
    end
  end
end
